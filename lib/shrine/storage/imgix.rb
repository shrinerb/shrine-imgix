require "imgix"
require "forwardable"
require "net/http"
require "uri"

class Shrine
  module Storage
    class Imgix
      PURGE_URL = "https://api.imgix.com/v2/image/purger"

      attr_reader :client, :storage

      # We initialize the Imgix client, and save the storage. We additionally
      # save the token as well, because `Imgix::Client` doesn't provide a
      # reader for the token.
      def initialize(storage:, **options)
        @client = ::Imgix::Client.new(options)
        @token = options[:token]
        @storage = storage
      end

      # We delegate all methods that are the same.
      extend Forwardable
      delegate [:upload, :download, :open, :read, :exists?, :clear!] => :storage

      # Purges the file from the source storage after moving it.
      def move(io, id, metadata = {})
        @storage.move(io, id, metadata)
        io.storage.purge(io.id) if io.storage.is_a?(Storage::Imgix)
      end

      def movable?(io, id)
        @storage.movable?(io, id) if @storage.respond_to?(:movable?)
      end

      # Purges the deleted file.
      def delete(id)
        @storage.delete(id)
        purge(id)
      end

      # Removes the file from Imgix, along with the generated versions.
      def purge(id)
        uri = URI.parse(PURGE_URL)
        uri.user = @token

        post(uri, "url" => url(id))
      end

      # Generates an Imgix URL to the file. All options passed in will be
      # transformed into URL parameters, check out the [reference] for all
      # available query parameters.
      #
      # [reference]: https://www.imgix.com/docs/reference
      def url(id, **options)
        client.path(id).to_url(**options)
      end

      private

      def post(uri, params = {})
        response = Net::HTTP.post_form(uri, params)
        response.error! if (400..599).cover?(response.code.to_i)
        response
      end
    end
  end
end

require "imgix"
require "forwardable"
require "net/http"
require "uri"

class Shrine
  module Storage
    class Imgix
      PURGE_URL = "https://api.imgix.com/v2/image/purger"

      attr_reader :client, :storage

      def initialize(storage:, **options)
        @client = ::Imgix::Client.new(options)
        @token = options[:token]
        @storage = storage
      end

      extend Forwardable
      delegate [:upload, :download, :open, :read, :exists?, :clear!] => :storage

      def move(io, id, metadata = {})
        @storage.move(io, id, metadata)
        purge(io.id)
      end

      def movable?(io, id)
        @storage.movable?(io, id) if @storage.respond_to?(:movable?)
      end

      def delete(id)
        @storage.delete(id)
        purge(id)
      end

      # Imgix-specific method
      def purge(id)
        uri = URI.parse(PURGE_URL)
        uri.user = @token

        post(uri, "url" => url(id))
      end

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

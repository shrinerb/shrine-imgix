require "imgix"
require "net/http"
require "uri"

warn "Shrine::Storage::Imgix is deprecated and will be removed in next major version. Use the new :imgix plugin instead."

class Shrine
  module Storage
    class Imgix
      PURGE_URL = "https://api.imgix.com/v2/image/purger"

      attr_reader :client, :storage

      # We initialize the Imgix client, and save the storage. We additionally
      # save the token as well, because `Imgix::Client` doesn't provide a
      # reader for the token.
      def initialize(storage:, include_prefix: false, **options)
        @client = ::Imgix::Client.new(options)
        @api_key = options.fetch(:api_key)
        @storage = storage
        @include_prefix = include_prefix

        instance_eval do
          # Purges the file from the source storage after moving it.
          def move(io, id, **options)
            @storage.move(io, id, **options)
            io.storage.purge(io.id) if io.storage.is_a?(Storage::Imgix)
          end if @storage.respond_to?(:move)

          def movable?(io, id)
            @storage.movable?(io, id)
          end if @storage.respond_to?(:movable?)

          def download(id)
            @storage.download(id)
          end if @storage.respond_to?(:download)

          def presign(*args)
            @storage.presign(*args)
          end if @storage.respond_to?(:presign)

          def clear!(*args)
            @storage.clear!(*args)
          end if @storage.respond_to?(:clear!)
        end
      end

      def upload(io, id, **options)
        @storage.upload(io, id, **options)
      end

      def open(id)
        @storage.open(id)
      end

      def exists?(id)
        @storage.exists?(id)
      end

      # Generates an Imgix URL to the file. All options passed in will be
      # transformed into URL parameters, check out the [reference] for all
      # available query parameters.
      #
      # [reference]: https://www.imgix.com/docs/reference
      def url(id, **options)
        id = [*@storage.prefix, id].join("/") if @include_prefix

        client.path(id).to_url(**options)
      end

      # Purges the deleted file.
      def delete(id)
        @storage.delete(id)
        purge(id)
      end

      # Removes the file from Imgix, along with the generated versions.
      def purge(id)
        uri = URI.parse(PURGE_URL)
        uri.user = @api_key

        post(uri, "url" => url(id))
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

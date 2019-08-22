require "imgix"

class Shrine
  module Plugins
    module Imgix
      def self.configure(uploader, **opts)
        opts[:client] = ::Imgix::Client.new(opts[:client]) if opts[:client].is_a?(Hash)

        uploader.opts[:imgix] ||= { prefix: true, purge: false }
        uploader.opts[:imgix].merge!(**opts)

        fail Error, ":client is required for imgix plugin" unless uploader.imgix_client
      end

      module ClassMethods
        def imgix_client
          opts[:imgix][:client]
        end
      end

      module FileMethods
        def imgix_url(**options)
          imgix_client.path(imgix_id).to_url(**options)
        end

        def delete
          super
          imgix_purge if imgix_purge?
        end

        def imgix_purge
          imgix_client.purge(imgix_id)
        end

        def imgix_id
          if imgix_prefix? && storage.respond_to?(:prefix)
            [*storage.prefix, id].join("/")
          else
            id
          end
        end

        private

        def imgix_client
          shrine_class.imgix_client
        end

        def imgix_prefix?
          shrine_class.opts[:imgix][:prefix]
        end

        def imgix_purge?
          shrine_class.opts[:imgix][:purge]
        end
      end
    end

    register_plugin(:imgix, Imgix)
  end
end

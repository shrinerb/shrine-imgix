# Shrine::Storage::Imgix

Provides [Imgix] integration for [Shrine].

Imgix is a service for processing images on the fly, and works with files
stored on Amazon S3.

## Installation

```ruby
gem "shrine-imgix"
```

## Usage

Imgix doesn't upload files directly, but instead it transfers images from
various sources (S3, Web Folder or Web Proxy), so you first need to set that up
(see the [Imgix documentation]). After this is set up, the Imgix Shrine
"storage" is used as a wrapper around the main storage of the source:

```rb
require "shrine/storage/imgix"
require "shrine/storage/s3"

imgix = Shrine::Storage::Imgix.new(
  storage:          Shrine::Storage::S3.new(**s3_options),
  include_prefix:   true, # set to false if you have prefix configured in Imgix source
  api_key:          "xzy123",                 #
  host:             "my-subdomain.imgix.net", # Imgix::Client options
  secure_url_token: "abc123", # optional      #
)

Shrine.storages[:store] = imgix
```

All options other than `:storage` and `:include_prefix` are used for
instantiating an `Imgix::Client`, see the [imgix] gem for information about all
possible options. The `:include_prefix` option decides whether the `#prefix`
of the underlying storage will be included in the generated Imgix URLs.

All storage actions are forwarded to the main storage, and deleted files are
automatically purged from Imgix. The only method that the Imgix storage
overrides is, of course, `#url`:

```rb
post.image.url(w: 150, h: 200, fit: "crop")
#=> "http://my-subdomain.imgix.net/943kdfs0gkfg.jpg?w=150&h=200&fit=crop"
```

See the [Imgix docs](https://www.imgix.com/docs/reference) for all available
URL options.

If you're using [imgix-rails] and want to use the `ix_image_tag` helper method,
you can extract the path portion of the URL and pass it on to the helper:

```erb
<%= ix_image_tag URI(photo.image.url).path, { w: 300, h: 500, fit: "crop" } %>
```

## Development

The tests for shrine-imgix uses S3, so you'll have to create an `.env` file with
appropriate credentials:

```sh
# .env
IMGIX_API_KEY="..."
IMGIX_HOST="..."
IMGIX_SECURE_URL_TOKEN="..." # optional
S3_ACCESS_KEY_ID="..."
S3_SECRET_ACCESS_KEY="..."
S3_REGION="..."
S3_BUCKET="..."
S3_PREFIX="..."
```

Afterwards you can run the tests:

```sh
$ bundle exec rake test
```

## License

[MIT](http://opensource.org/licenses/MIT)

[Imgix]: https://www.imgix.com/
[Shrine]: https://github.com/janko/shrine
[imgix]: https://github.com/imgix/imgix-rb
[Imgix documentation]: https://www.imgix.com/docs
[imgix-rails]: https://github.com/imgix/imgix-rails

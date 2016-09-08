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

s3 = Shrine::Storage::S3.new(**s3_options)
imgix = Shrine::Storage::Imgix.new(
  storage: s3,
  host: "my-subdomain.imgix.net",
  token: "abc123",
)

Shrine.storages[:store] = imgix
```

All options other than `:storage` are used for instantiating an `Imgix::Client`,
so see the [imgix] gem for information about all possible options.

All storage actions are forwarded to the main storage, and deleted files are
automatically purged from Imgix. The only method that the Imgix storage
overrides is, of course, `#url`:

```rb
post.image.url(w: 150, h: 200, fit: "crop")
#=> "http://my-subdomain.imgix.net/943kdfs0gkfg.jpg?w=150&h=200&fit=crop"
```

See the [Imgix docs](https://www.imgix.com/docs/reference) for all available
URL options.

## Development

The tests for shrine-imgix uses S3, so you'll have to create an `.env` file with
appropriate credentials:

```sh
# .env
IMGIX_API_KEY="..."
IMGIX_HOST="..."
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
[Shrine]: https://github.com/janko-m/shrine
[imgix]: https://github.com/imgix/imgix-rb
[Imgix documentation]: https://www.imgix.com/docs

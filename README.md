# Shrine::Storage::Imgix

Provides [Imgix] integration for [Shrine].

Imgix is a service for processing images on the fly, and works with files
stored on external services such as AWS S3 or Google Cloud Storage.

## Installation

```ruby
gem "shrine-imgix"
```

## Configuring

Load the `imgix` plugin with Imgix client settings:

```rb
Shrine.plugin :imgix, client: {
  host:             "your-subdomain.imgix.net",
  secure_url_token: "abc123",
}
```

You can also pass in an `Imgix::Client` object directly:

```rb
require "imgix"

imgix_client = Imgix::Client.new(
  host:             "your-subdomain.imgix.net",
  secure_url_token: "abc123",
)

Shrine.plugin :imgix, client: imgix_client
```

### Path prefix

If you've configured a "Path Prefix" on your Imgix source, and you also have
`:prefix` set on your Shrine storage, you'll need tell the `imgix` plugin to
exclude the storage prefix from generated URLs:

```rb
Shrine.plugin :imgix, client: ..., prefix: false
```

## Usage

You can generate an Imgix URL for a `Shrine::UploadedFile` object by calling
`#imgix_url`:

```rb
photo.image.imgix_url(w: 150, h: 200, fit: "crop")
#=> "http://my-subdomain.imgix.net/943kdfs0gkfg.jpg?w=150&h=200&fit=crop"
```

See the [Imgix docs][url reference] for all available URL options.

### Rails

If you're using [imgix-rails] and want to use the `ix_*` helpers, you can use
`#imgix_id` to retrieve the Imgix path:

```erb
<%= ix_image_tag photo.image.imgix_id, url_params: { w: 300, h: 500, fit: "crop" } %>
```

### Purging

If you want images to be automatically [purged][purging] from Imgix on
deletion, you can set `:purge` to `true`:

```rb
Shrine.plugin :imgix, client: ..., purge: true
```

You can also purge manually with `Shrine::UploadedFile#imgix_purge`:

```rb
photo.image.imgix_purge
```

Note that purging requires passing the `:api_key` option to your Imgix client.

## Development

You can run the test suite with:

```sh
$ bundle exec rake test
```

## License

[MIT](http://opensource.org/licenses/MIT)

[Imgix]: https://www.imgix.com/
[Shrine]: https://github.com/janko/shrine
[imgix]: https://github.com/imgix/imgix-rb
[url reference]: https://docs.imgix.com/apis/url
[imgix-rails]: https://github.com/imgix/imgix-rails
[purging]: https://docs.imgix.com/setup/purging-images

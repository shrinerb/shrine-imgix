require "test_helper"
require "shrine/storage/linter"
require "shrine/storage/s3"
require "down"

describe Shrine::Storage::Imgix do
  def imgix(options = {})
    options[:storage]          ||= s3
    options[:host]             ||= ENV.fetch("IMGIX_HOST")
    options[:api_key]          ||= ENV.fetch("IMGIX_API_KEY")
    options[:secure_url_token] ||= ENV.fetch("IMGIX_SECURE_URL_TOKEN")

    Shrine::Storage::Imgix.new(options)
  end

  def s3
    Shrine::Storage::S3.new(
      bucket:            ENV.fetch("S3_BUCKET"),
      region:            ENV.fetch("S3_REGION"),
      access_key_id:     ENV.fetch("S3_ACCESS_KEY_ID"),
      secret_access_key: ENV.fetch("S3_SECRET_ACCESS_KEY"),
      prefix:            ENV.fetch("S3_PREFIX")
    )
  end

  before do
    @imgix = imgix
  end

  after do
    @imgix.clear!
  end

  it "passes the linter" do
    Shrine::Storage::Linter.call(@imgix)
  end

  describe "#url" do
    it "creates URL parameters out of options" do
      url = @imgix.url("image.jpg", w: 150)

      assert_includes url, ENV["IMGIX_HOST"]
      assert_includes url, "w=150"
    end

    it "creates a valid downloadable URL" do
      @imgix.upload(image, "image.jpg", shrine_metadata: {"mime_type" => "image/jpeg"})
      url = @imgix.url("image.jpg", w: 150)
      tempfile = Down.download(url)

      assert_equal "image/jpeg", tempfile.content_type
    end
  end
end

require "test_helper"
require "shrine/plugins/imgix"
require "shrine/storage/memory"
require "stringio"

describe Shrine::Plugins::Imgix do
  before do
    @shrine = Class.new(Shrine)
    @shrine.storages[:memory] = Shrine::Storage::Memory.new
  end

  describe ".configure" do
    it "accepts :client as a hash" do
      @shrine.plugin :imgix, client: { domain: "shrine.imgix.net" }

      assert_instance_of Imgix::Client, @shrine.imgix_client
      assert_match "https://shrine.imgix.net/foo", @shrine.imgix_client.path("/foo").to_url
    end

    it "accepts :client as an Imgix::Client" do
      @shrine.plugin :imgix, client: Imgix::Client.new(domain: "shrine.imgix.net")

      assert_instance_of Imgix::Client, @shrine.imgix_client
      assert_match "https://shrine.imgix.net/foo", @shrine.imgix_client.path("/foo").to_url
    end

    it "fails on missing :client option" do
      assert_raises Shrine::Error do
        @shrine.plugin :imgix
      end
    end
  end

  describe "UploadedFile" do
    before do
      @shrine.plugin :imgix, client: { domain: "shrine.imgix.net", include_library_param: false }

      @file = @shrine.upload(StringIO.new("file"), :memory, location: "foo")
    end

    describe "#imgix_url" do
      it "returns imgix URL" do
        assert_equal "https://shrine.imgix.net/foo", @file.imgix_url
      end

      it "accepts transformation options" do
        assert_equal "https://shrine.imgix.net/foo?w=100&h=100", @file.imgix_url(w: 100, h: 100)
      end

      it "includes storage prefix" do
        @shrine.storages[:memory].instance_eval { def prefix; "prefix"; end }

        assert_equal "https://shrine.imgix.net/prefix/foo", @file.imgix_url
      end

      it "doesn't include storage prefix when disabled" do
        @shrine.plugin :imgix, prefix: false
        @shrine.storages[:memory].instance_eval { def prefix; "prefix"; end }

        assert_equal "https://shrine.imgix.net/foo", @file.imgix_url
      end
    end

    describe "#delete" do
      it "purges when purging is enabled" do
        @shrine.plugin :imgix, purge: true

        @shrine.imgix_client.expects(:purge).with("foo")

        @file.delete
      end

      it "includes prefix when purging" do
        @shrine.plugin :imgix, purge: true
        @shrine.storages[:memory].instance_eval { def prefix; "prefix"; end }

        @shrine.imgix_client.expects(:purge).with("prefix/foo")

        @file.delete
      end

      it "doesn't purge by default" do
        @shrine.imgix_client.expects(:purge).never

        @file.delete
      end
    end
  end
end

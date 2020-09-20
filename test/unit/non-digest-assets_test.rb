# frozen_string_literal: true

require "test_helper"
require "non-digest-assets"
require "tmpdir"
require "fileutils"

describe "NonDigestAssets" do
  describe ".assets" do
    it "returns its arguments if there are no whitelisted assets" do
      NonDigestAssets.whitelist = []
      _(NonDigestAssets.assets(%w(foo bar))).must_equal %w(foo bar)
    end

    it "returns only whitelisted parts of arguments if there are whitelisted assets" do
      NonDigestAssets.whitelist = %w(bar baz)
      _(NonDigestAssets.assets(%w(foo bar))).must_equal ["bar"]
    end
  end
end

describe "NonDigestAssets::CompileWithNonDigest" do
  let(:sprockets) do
    klass = Class.new do
      attr_reader :dir

      def initialize
        @dir = Dir.mktmpdir
      end

      def compile
        files = ["#{dir}/foo-deadbeef.css", "#{dir}/bar-f00df00d.css"]
        files.each { |it| make_asset it }
      end

      def assets
        [["foo.css", "foo-deadbeef.css"],
         ["bar.css", "bar-f00df00d.css"]]
      end

      def logger
        @logger ||= Logger.new(StringIO.new)
      end

      private

      def make_asset(asset)
        FileUtils.touch asset
      end
    end
    klass.prepend NonDigestAssets::CompileWithNonDigest
    klass.new
  end

  before do
    NonDigestAssets.whitelist = []
  end

  describe "#compile" do
    it "returns the result of the super method" do
      result = sprockets.compile
      _(result).must_equal ["#{sprockets.dir}/foo-deadbeef.css",
                            "#{sprockets.dir}/bar-f00df00d.css"]
    end

    describe "if regular files for each asset exist but gzipped files do not" do
      it "creates only non-digest versions for each asset" do
        sprockets.compile
        _("#{sprockets.dir}/foo.css").path_must_exist
        _("#{sprockets.dir}/bar.css").path_must_exist
        _("#{sprockets.dir}/foo.css.gz").path_wont_exist
        _("#{sprockets.dir}/bar.css.gz").path_wont_exist
      end

      it "does not copy files for non-whitelisted assets" do
        NonDigestAssets.whitelist = ["bar.css"]
        sprockets.compile
        _("#{sprockets.dir}/foo.css").path_wont_exist
        _("#{sprockets.dir}/bar.css").path_must_exist
      end
    end

    describe "if no files exist for each asset" do
      before do
        sprockets.define_singleton_method :make_asset do |it|
          # Do nothing
        end
      end

      it "does not create any non-digest versions for each asset" do
        sprockets.compile
        _("#{sprockets.dir}/foo.css").path_wont_exist
        _("#{sprockets.dir}/bar.css").path_wont_exist
        _("#{sprockets.dir}/foo.css.gz").path_wont_exist
        _("#{sprockets.dir}/bar.css.gz").path_wont_exist
      end
    end

    describe "if both regular and gzipped files exist for each asset" do
      before do
        sprockets.define_singleton_method :make_asset do |it|
          FileUtils.touch it
          FileUtils.touch "#{it}.gz"
        end
      end

      it "creates both regular and gzipped non-digest versions for each asset" do
        sprockets.compile
        _("#{sprockets.dir}/foo.css").path_must_exist
        _("#{sprockets.dir}/bar.css").path_must_exist
        _("#{sprockets.dir}/foo.css.gz").path_must_exist
        _("#{sprockets.dir}/bar.css.gz").path_must_exist
      end

      it "does not copy files for non-whitelisted assets" do
        NonDigestAssets.whitelist = ["bar.css"]
        sprockets.compile
        _("#{sprockets.dir}/foo.css").path_wont_exist
        _("#{sprockets.dir}/bar.css").path_must_exist
        _("#{sprockets.dir}/foo.css.gz").path_wont_exist
        _("#{sprockets.dir}/bar.css.gz").path_must_exist
      end
    end
  end
end

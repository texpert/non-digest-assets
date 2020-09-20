require 'test_helper'
require 'non-digest-assets'

describe "NonDigestAssets" do
  describe ".assets" do
    it "returns its arguments if there are no whitelisted assets" do
      NonDigestAssets.whitelist = []
      _(NonDigestAssets.assets(["foo", "bar"])).must_equal ["foo", "bar"]
    end

    it "returns only whitelisted parts of arguments if there are whitelisted assets" do
      NonDigestAssets.whitelist = ["bar", "baz"]
      _(NonDigestAssets.assets(["foo", "bar"])).must_equal ["bar"]
    end
  end
end

# frozen_string_literal: true

require "spec_helper"
require "non-digest-assets"

RSpec.describe NonDigestAssets do
  describe ".filter_assets" do
    it "returns its arguments if there are no whitelisted assets" do
      described_class.whitelist = []
      expect(described_class.filter_assets(%w(foo bar))).to eq %w(foo bar)
    end

    it "returns only whitelisted parts of arguments if there are whitelisted assets" do
      described_class.whitelist = %w(bar baz)
      expect(described_class.filter_assets(%w(foo bar))).to eq ["bar"]
    end
  end

  describe ".assets (deprecated)" do
    it "returns its arguments if there are no whitelisted assets" do
      described_class.whitelist = []
      expect(described_class.assets(%w(foo bar))).to eq %w(foo bar)
    end

    it "returns only whitelisted parts of arguments if there are whitelisted assets" do
      described_class.whitelist = %w(bar baz)
      expect(described_class.assets(%w(foo bar))).to eq ["bar"]
    end
  end
end

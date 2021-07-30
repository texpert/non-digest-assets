# frozen_string_literal: true

require "sprockets/manifest"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/deprecation"

module NonDigestAssets
  mattr_accessor :whitelist
  @@whitelist = []

  class << self
    def filter_assets(asset_list)
      if whitelist.empty?
        asset_list
      else
        asset_list.select do |logical_path, _digest_path|
          whitelist.any? do |item|
            item === logical_path
          end
        end
      end
    end

    def assets(asset_list)
      filter_assets(asset_list)
    end

    ActiveSupport::Deprecation
      .deprecate_methods(self, assets: "use filter_assets instead",
                         deprecator: ActiveSupport::Deprecation.new("2.0.0",
                                                                    "non-digest-assets"))
  end

  module CompileWithNonDigest
    # Copy an asset and preserve atime and mtime attributes. If the file exists
    # and is not owned by the calling user, the utime call will fail so we just
    # delete the target file first in any case.
    def copy_file(from, to)
      FileUtils.rm_f to
      FileUtils.copy_file from, to, :preserve_attributes
    end

    def compile(*args)
      paths = super
      NonDigestAssets.filter_assets(assets).each do |(logical_path, digest_path)|
        full_digest_path = File.join dir, digest_path
        full_digest_gz_path = "#{full_digest_path}.gz"
        full_non_digest_path = File.join dir, logical_path
        full_non_digest_gz_path = "#{full_non_digest_path}.gz"

        if File.exist? full_digest_path
          logger.debug "Writing #{full_non_digest_path}"
          copy_file full_digest_path, full_non_digest_path
        else
          logger.debug "Could not find: #{full_digest_path}"
        end
        if File.exist? full_digest_gz_path
          logger.debug "Writing #{full_non_digest_gz_path}"
          copy_file full_digest_gz_path, full_non_digest_gz_path
        else
          logger.debug "Could not find: #{full_digest_gz_path}"
        end
      end

      paths
    end
  end
end

Sprockets::Manifest.prepend NonDigestAssets::CompileWithNonDigest

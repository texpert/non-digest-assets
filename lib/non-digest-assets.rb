# frozen_string_literal: true

require "sprockets/manifest"
require "active_support/core_ext/module/attribute_accessors"

module NonDigestAssets
  mattr_accessor :asset_selectors
  @@asset_selectors = []

  class << self
    def filter_assets(asset_list)
      if asset_selectors.empty?
        asset_list
      else
        asset_list.select do |logical_path, _digest_path|
          asset_selectors.any? do |item|
            item === logical_path
          end
        end
      end
    end

    # Copy an asset and preserve atime and mtime attributes. If the file exists
    # and is not owned by the calling user, the utime call will fail so we just
    # delete the target file first in any case.
    def copy_file(from, to)
      return if from == to

      FileUtils.rm_f to
      FileUtils.copy_file from, to, :preserve_attributes
    end
  end

  module CompileWithNonDigest
    def compile(*args)
      paths = super
      NonDigestAssets.filter_assets(assets).each do |(logical_path, digest_path)|
        full_digest_path = File.join dir, digest_path
        full_digest_gz_path = "#{full_digest_path}.gz"
        full_non_digest_path = File.join dir, logical_path
        full_non_digest_gz_path = "#{full_non_digest_path}.gz"

        if File.exist? full_digest_path
          logger.debug "Writing #{full_non_digest_path}"
          NonDigestAssets.copy_file full_digest_path, full_non_digest_path
        else
          logger.debug "Could not find: #{full_digest_path}"
        end
        if File.exist? full_digest_gz_path
          logger.debug "Writing #{full_non_digest_gz_path}"
          NonDigestAssets.copy_file full_digest_gz_path, full_non_digest_gz_path
        else
          logger.debug "Could not find: #{full_digest_gz_path}"
        end
      end

      paths
    end
  end
end

Sprockets::Manifest.prepend NonDigestAssets::CompileWithNonDigest

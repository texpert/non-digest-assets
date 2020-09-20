require "sprockets/manifest"
require "active_support/core_ext/module/attribute_accessors"

module NonDigestAssets
  mattr_accessor :whitelist
  @@whitelist = []

  class << self
    def assets(assets)
      return assets if whitelist.empty?
      whitelisted_assets(assets)
    end

    private

    def whitelisted_assets(assets)
      assets.select do |logical_path, digest_path|
        whitelist.any? do |item|
          item === logical_path
        end
      end
    end
  end

  module CompileWithNonDigest
    # Copy an asset and preserve atime and mtime attributes. If the file exists
    # and is not owned by the calling user, the utime call will fail so we just
    # delete the target file first in any case.
    def copy_file(from, to)
      FileUtils.rm_f to
      FileUtils.copy_file from, to, :preserve_attributes
    end

    def compile *args
      paths = super
      NonDigestAssets.assets(assets).each do |(logical_path, digest_path)|
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

Sprockets::Manifest.send(:prepend, NonDigestAssets::CompileWithNonDigest)

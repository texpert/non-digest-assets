# frozen_string_literal: true

require "test_helper"
require "yaml"

def in_clean_bundler_environment(*args)
  system(*%w(/usr/bin/env -u RUBYOPT -u BUNDLE_BIN_PATH -u BUNDLE_GEMFILE) + args)
end

def update_bundle(label)
  return if in_clean_bundler_environment("bundle", "update", "--quiet", "--local")

  puts "Starting remote update of the bundle for #{label}"
  return if in_clean_bundler_environment("bundle", "update")

  raise "Unable to initialize test environment for #{label}"
end

def run_command(command_array)
  result = false
  out, err = capture_subprocess_io do
    result = in_clean_bundler_environment(*command_array)
  end
  # If the command failed, make it print any error messages
  _(err).must_equal "" unless result
  out
end

def run_tests(command_array = %w(bundle exec rake))
  run_command command_array
end

SPROCKETS_3_DIGEST = "f0d704deea029cf000697e2c0181ec173a1b474645466ed843eb5ee7bb215794"
SPROCKETS_4_DIGEST = "4998ce12ecefa6ba42de36e4beac458527529608f8cf0fe6c97acd87850045e4"

VERSIONS = [
  ["5.0", 3, "rails50_app", SPROCKETS_3_DIGEST],
  ["5.1", 3, "rails51_app", SPROCKETS_3_DIGEST],
  ["5.2", 3, "rails52_app", SPROCKETS_3_DIGEST],
  ["6.0", 4, "rails60_app", SPROCKETS_4_DIGEST]
].freeze

VERSIONS.each do |rails_version, sprockets_version, appdir, digest_key|
  next if RUBY_VERSION < "2.5.0" && sprockets_version.to_i > 3

  label = "Rails #{rails_version} with sprockets #{sprockets_version}"
  Dir.chdir "fixtures/#{appdir}" do
    update_bundle label
  end

  describe "#{label} using non-digest-assets" do
    it "creates assets, both with and without digest" do
      Dir.chdir "fixtures/#{appdir}" do
        run_command %w(bundle exec rake assets:clobber)
        _("public/assets/").path_wont_exist
        run_command %w(bundle exec rake assets:precompile)
        _("public/assets/application-#{digest_key}.css").path_must_exist
        _("public/assets/application.css").path_must_exist
        _("public/assets/application-#{digest_key}.css.gz").path_must_exist
        _("public/assets/application.css.gz").path_must_exist
      end
    end
  end
end

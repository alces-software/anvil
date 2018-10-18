
require 'json'
require 'parallel'
require 'open-uri'
require 'highline/import'

require_relative File.join(ENV['FL_ROOT'], 'lib/flight_direct/version.rb')

namespace :packages do
  desc 'Import packages from a local source'
  task import: :environment do
    raise 'The ANVIL_LOCAL_DIR has not been set' unless ENV['ANVIL_LOCAL_DIR']
    raise 'The ANVIL_BASE_URL has not been set' unless ENV['ANVIL_BASE_URL']
    files = Dir[package_path('**/*.zip')]
    files.define_singleton_method(:delete_if_saveable) do
      self.delete_if { |f| add_package_from_zip_path(f) }
    end
    count = files.length + 1 # Fudge the initial condition check
    loop while count > (count = files.delete_if_saveable.length)
    raise <<-ERROR.strip_heredoc if count > 0
      Failed to import the following packages:
      #{files.join("\n")}
    ERROR
  end

  def package_path(relative_path)
    File.join(ENV['ANVIL_LOCAL_DIR'], 'packages', relative_path)
  end

  def extract_package_url(absolute_path)
    relative_path = absolute_path&.sub(ENV['ANVIL_LOCAL_DIR'], '')
    File.join(ENV['ANVIL_BASE_URL'], relative_path)
  end

  def add_package_from_zip_path(zip_path)
    user = User.where(name: 'alces').first_or_create
    url = extract_package_url(zip_path)
    Package.build_from_zip(
      user: user, package_url: url, file: zip_path
    ).save
  end
end

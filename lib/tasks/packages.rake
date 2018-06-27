
require 'json'
require 'parallel'
require 'open-uri'

namespace :packages do
  desc 'Downloads all the rake packages'
  task download: :environment do
    raise 'The ANVIL_UPSTREAM has not been set' unless ENV['ANVIL_UPSTREAM']
    raise 'The ANVIL_LOCAL_DIR has not been set' unless ENV['ANVIL_LOCAL_DIR']
    packages = JSON.parse(
      Net::HTTP.get(URI("#{ENV['ANVIL_UPSTREAM']}/v1/packages")),
      object_class: OpenStruct
    )
    Parallel.map(packages.data, in_threads: 10) do |metadata|
      uri = URI.parse(metadata.attributes.packageUrl)
      path = File.join(ENV['ANVIL_LOCAL_DIR'], URI.unescape(uri.path))
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, "wb") do |save_file|
        open(uri.to_s) { |line| save_file.write(line.read) }
      end
    end
  end

  desc 'Import packages from a local source'
  task import: :environment do
    raise 'The ANVIL_LOCAL_DIR has not been set' unless ENV['ANVIL_LOCAL_DIR']
    raise 'The ANVIL_BASE_URL has not been set' unless ENV['ANVIL_BASE_URL']
    user = User.where(name: 'alces').first_or_create
    category = Category.where(name: 'uncategorised').first_or_create
    Dir[File.join(ENV['ANVIL_LOCAL_DIR'], '**/*.zip')].each do |zip_path|
      relative_path = zip_path.sub(ENV['ANVIL_LOCAL_DIR'], '')
      url = File.join(ENV['ANVIL_BASE_URL'], relative_path)
      Package.build_from_zip(
        user: user, category: category, package_url: url, file: zip_path
      ).save!
    end
  end
end

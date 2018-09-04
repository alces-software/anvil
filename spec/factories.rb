
require 'helpers/zip_maker'

FactoryBot.define do
  factory :package do
    name 'factory-bot-package'
    version '0.0.1'
    licence 'Some MIT~Open Source Test License'
    package_url 'www.example.com/alces/test-package/url'
    user
    category
    zip_file_path "/tmp/anvil-factory-package#{Time.now.to_i}.zip"

    # Hacks the creation of the zip file. The zip file is made before create
    # and then destroyed afterwards
    before :create do |package|
      Helpers::ZipMaker.with_metadata(
        package.zip_file_path,
        type: 'package',
        attributes: {
          name: package.name
        }
      )
    end
    after :create do |package|
      FileUtils.rm package.zip_file_path
    end
  end

  factory :user do
    name 'factory-bot-user'
  end

  factory :category do
    name 'factory-bot-category'
  end
end

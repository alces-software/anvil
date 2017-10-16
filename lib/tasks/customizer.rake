require 'open-uri'
require 'yaml'

namespace :customizer do

  S3_BASE_URL = 'https://s3-eu-west-1.amazonaws.com/alces-flight-profiles-eu-west-1/2017.1/features'

  def do_customizer_import
    index = YAML.load(open("#{S3_BASE_URL}/index.yml") { |f| f.read })

    alces = User.find_by_name('alces')

    index['profiles'].each do |name, profile|
      if !profile.include?('tags') || !profile['tags'].include?('hidden')
        customizer = Customizer.where(
            user: alces,
            name: name
        ).first_or_create
        customizer.s3_url = "#{S3_BASE_URL}/#{name}"
        customizer.save!

        if profile.include?('tags')
          customizer.tags = profile['tags'].map { |tag| Tag.get_or_create(tag) }
        end

      else
        puts "Skipping hidden profile #{name}"
      end
    end
  end

  desc 'Delete existing and import Alces feature profiles into Forge'
  task :import => :environment do
    alces = User.find_by_name('alces')
    Customizer.where(user: alces).delete_all
    do_customizer_import
  end

  desc 'Update Alces feature profiles from S3'
  task :update => :environment do
    do_customizer_import
  end

end

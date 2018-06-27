
FactoryBot.define do
  factory :package do
    name 'factory-bot-package'
    version '0.0.1'
    licence 'Some MIT~Open Source Test License'
    package_url 'www.example.com/alces/test-package/url'
    user
    category
  end

  factory :user do
    name 'factory-bot-user'
  end

  factory :category do
    name 'factory-bot-category'
  end
end

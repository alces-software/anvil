class Site < ApplicationRecord
  has_many :users
  has_many :documents
end

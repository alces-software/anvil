class Package < ApplicationRecord
  include Taggable
  belongs_to :user
  belongs_to :category

  has_and_belongs_to_many :dependencies,
                          class_name: 'Package',
                          autosave: true,
                          join_table: 'package_dependencies',
                          foreign_key: 'parent_id',
                          association_foreign_key: 'dependent_id'

  validates :name,
            presence: true,
            length: {
                maximum: 512
            }

  validates :version,
            uniqueness: {
                scope: [:user, :name]
            }

  validates :licence,
            length: {
                maximum: 512
            }

  validates :package_url,
            presence: true

  def username
    # Convenience method to embed username in package resource without including everything to do with user
    user.name
  end
end

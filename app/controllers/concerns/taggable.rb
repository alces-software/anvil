module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable
    has_many :tags, through: :taggings

    def tag_names
      tags.all.map(&:id)
    end

    def tag_names=(names)
      tags = names.map { |t| Tag.get_or_create(t) }
    end
  end
end

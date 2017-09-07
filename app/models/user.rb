class User < ApplicationRecord

  require 'json_web_token'

  has_many :articles
  has_many :customizers
  has_many :gridware_packages

  validates :name, uniqueness: true

  alias_attribute :gridware, :gridware_packages

  def self.from_jwt_token(token)
    claims = ::JsonWebToken.decode(token)  # handles signature verification too

    user = where(flight_id: claims.fetch('flight_id')).first_or_create

    user.tap do |u|
      # The following is _not_ provided as a block to `first_or_create` since we
      # want to update the user's details locally in the event that they have
      # changed in the SSO database. `first_or_create` only executes the block
      # on create.
      u.email = claims.fetch('email')
      u.name = claims.fetch('username')
      u.save
    end

  end

end

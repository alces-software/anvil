class User < ApplicationRecord

  require 'json_web_token'

  has_many :articles
  has_many :customizers
  has_many :gridware, class_name: 'GridwarePackage'
  has_many :packages
  has_many :collections

  validates :name, uniqueness: true

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

  # This method is only intended to be used in development for generating
  # tokens. It is not guaranteed to be the same as the FLIGHT_SSO server
  def generate_jwt_token
    JsonWebToken.encode({
      'username' => name, 'email' => email, 'flight_id' => flight_id
    })
  end
end

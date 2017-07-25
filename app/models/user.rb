class User < ApplicationRecord

  require 'json_web_token'

  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :articles
  has_many :customizers
  has_many :gridware_packages

  validates :name, uniqueness: true

  alias_attribute :gridware, :gridware_packages

  def as_json(options)
    super.tap do |h|
      h[:authentication_token] = authentication_token if ::JsonWebToken.enabled?
    end
  end

  def authentication_token
    JsonWebToken.encode({user_id: id}) if ::JsonWebToken.enabled?
  end

end

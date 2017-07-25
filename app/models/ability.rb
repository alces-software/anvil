class Ability
  include CanCan::Ability

  def initialize(user)
    # Content is public to read
    can :read, Article
    can :read, Customizer
    can :read, GridwarePackage
    can :read, User
  end
end

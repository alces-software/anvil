class Ability
  include CanCan::Ability

  def initialize(user)
    # Content and user profiles are public to read
    can :read, Article
    can :read, Customizer
    can :read, GridwarePackage
    can :read, User
    # Anyone can create content, as long as they're logged in
    if user.present?
      can :create, Article
      can :create, Customizer
      can :create, GridwarePackage

      # And we can update our own stuff
      can :update, Article, user_id: user.id
      can :update, Customizer, user_id: user.id
      can :update, GridwarePackage, user_id: user.id
    end
  end
end

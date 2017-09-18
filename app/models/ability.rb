class Ability
  include CanCan::Ability

  def initialize(user)
    # Content and user profiles are public to read
    can :read, Article
    can :read, Customizer
    can :read, GridwarePackage
    can :read, User

    # Current assumption: all collections are public.
    # We might want to introduce private or privately-shared collections at some point.
    can :read, Collection

    # Anyone can create content, as long as they're logged in
    if user.present?
      can :create, Article
      can :create, Customizer
      can :create, GridwarePackage
      can :create, Collection
      can :create, CollectionMembership

      # And we can update our own stuff
      can :update, Article, user_id: user.id
      can :update, Customizer, user_id: user.id
      can :update, GridwarePackage, user_id: user.id
      can :update, Collection, user_id: user.id
      can :update, CollectionMembership, collection: { user_id: user.id }

    end
  end
end

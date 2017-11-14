class Ability
  include CanCan::Ability

  def initialize(user)
    # Content and user profiles are public to read
    can :read, Article
    can :read, User
    can :read, Package

    # Current assumption: all collections are public.
    # We might want to introduce private or privately-shared collections at some point.
    can :read, Collection

    # Anyone can create content, as long as they're logged in
    if user.present?
      can :create, Article
      can :create, Collection
      can :create, CollectionMembership
      can :create, Package

      # And we can update our own stuff
      can :update, Article, user_id: user.id
      can :update, Collection, user_id: user.id
      can :update, CollectionMembership, collection: { user_id: user.id }
      can :update, Package, user_id: user.id

    end
  end
end

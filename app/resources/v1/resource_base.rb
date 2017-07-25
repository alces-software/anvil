#==============================================================================
# Copyright (C) 2015-2016 Stephen F Norledge & Alces Software Ltd.
#
# This file is part of Alces FlightDeck.
#
# All rights reserved, see LICENSE.txt.
#==============================================================================
module V1
  class ResourceBase < JSONAPI::Resource
    abstract
    before_save :check_save_authorization

    before_remove do check_authorization(:destroy) end

    class << self
      def records(options={})
        current_ability = options[:context][:current_ability] || Ability.new(nil)
        current_ability.authorize!(:read, _model_class)
        _model_class.accessible_by(current_ability)
      end
    end

    def records_for(relation_name)
      relationship = self.class._relationships[relation_name]
      current_ability = context[:current_ability] || Ability.new(nil)
      relationship_name = relationship.relation_name(context: context)

      case relationship
      when JSONAPI::Relationship::ToOne
        record = @model.public_send(relationship_name)
        record if current_ability.can?(:read, record)
      when JSONAPI::Relationship::ToMany
        @model.public_send(relationship_name).accessible_by(current_ability)
      end
    end

    def is_new?
      @model.new_record?
    end

    private

    def check_save_authorization
      action = is_new? ? :create : :update
      check_authorization(action)
    end

    def check_authorization(action)
      current_ability = context[:current_ability] || Ability.new(nil)
      current_ability.authorize!(action, @model)
    end

  end
end

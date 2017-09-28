module V1
  class JSONAPIResourceController < ApplicationController
    include JSONAPI::ActsAsResourceController

    def context
      {
          abridged: params.has_key?(:abridged),
          current_ability: current_ability,
          current_user: current_user,
      }
    end

  end
end

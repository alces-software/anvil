module V1
  class JSONAPIResourceController < ApplicationController
    include JSONAPI::ActsAsResourceController

    def context
      {
          current_ability: current_ability,
          current_user: current_user,
      }
    end

  end
end

module V1
  class SearchController < ApplicationController
    def search
      render :json => { :query => params[:q] }
    end
  end
end

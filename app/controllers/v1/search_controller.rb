module V1
  class SearchController < ApplicationController
    def search

      query = params[:q]
      gridware_packages = GridwarePackage.where('name LIKE ?', "%#{params[:q]}%").accessible_by(current_ability)
      customizers = Customizer.where('name LIKE ?', "%#{params[:q]}%").accessible_by(current_ability)
      articles = Article.where('title LIKE ?', "%#{params[:q]}%").accessible_by(current_ability)
      users = User.where('name LIKE ?', "%#{params[:q]}%").accessible_by(current_ability)

      result = {
          query: query,
          gridware: {},
          customizers: {},
          articles: {},
          users: {}
      }

      gridware_packages.each do |g|
        result[:gridware][g.id] = {
            name: g.name,
            version: g.version,
            username: g.user.name,
            summary: g.summary,
            updatedAt: g.updated_at
        }
      end

      customizers.each do |c|
        result[:customizers][c.id] = {
            name: c.name,
            username: c.user.name,
            description: c.description,
            updatedAt: c.updated_at
        }
      end

      articles.each do |a|
        result[:articles][a.id] = {
            title: a.title,
            username: a.user.name,
            updatedAt: a.updated_at
        }
      end

      users.each do |u|
        result[:users][u.id] = {
            name: u.name
        }
      end

      render :json => result
    end
  end
end

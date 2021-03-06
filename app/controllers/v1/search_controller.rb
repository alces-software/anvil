module V1
  class SearchController < ApplicationController
    def search

      query = params[:q]

      categories = params[:cat].map do |cat|
        Category.find_by_name(cat) || nil
      end.compact rescue []

      packages = Package.where('lower(name) LIKE ?', "%#{params[:q].downcase}%").accessible_by(current_ability).select do |pkg|
        categories.empty? || !(pkg.category.with_all_parents & categories).empty?
      end
      articles = Article.where('lower(title) LIKE ?', "%#{params[:q].downcase}%").accessible_by(current_ability)
      users = User.where('lower(name) LIKE ?', "%#{params[:q].downcase}%").accessible_by(current_ability)

      result = {
          query: query,
          packages: {},
          articles: {},
          users: {}
      }

      packages.each do |p|
        result[:packages][p.id] = {
          name: p.name,
          summary: p.summary,
          version: p.version,
          description: p.description,
          username: p.user.name,
          categories: p.category.with_all_parents.map { |c| { name: c.name, id: c.id, parent: c.parent_id } }
        }
      end

      articles.each do |a|
        result[:articles][a.id] = {
            title: a.title,
            summary: a.summary,
            tagNames: a.tag_names,
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

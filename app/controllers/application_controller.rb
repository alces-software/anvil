class ApplicationController < ActionController::Base

  load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |exception|
    errorObject = {
        title: 'Forbidden',
        detail: exception.message,
        code: "forbidden",
        status: 403,
        user: current_user
    }
    render json: {errors: [errorObject]}, status: :forbidden
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_user)
  end

end

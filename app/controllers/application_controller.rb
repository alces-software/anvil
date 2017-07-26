class ApplicationController < ActionController::Base

  rescue_from CanCan::AccessDenied do |exception|
    errorObject = {
        title: 'Forbidden',
        detail: exception.message,
        code: 'forbidden',
        status: 403
    }
    render json: {errors: [errorObject]}, status: :forbidden
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_user)
  end

end

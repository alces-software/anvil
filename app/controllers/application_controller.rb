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

  def current_user
    auth_cookie = cookies['flight_sso']
    auth_header = request.headers['Authorization']

    return nil unless auth_cookie.present? || auth_header.present?

    token = auth_header.present? ? auth_header.split(' ').last : auth_cookie

    return nil unless token.present?

    User.from_jwt_token(token) rescue nil

  end

end

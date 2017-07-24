class ApplicationController < ActionController::API

  rescue_from CanCan::AccessDenied do |exception|
    errorObject = {
        title: 'Forbidden',
        detail: exception.message,
        code: "forbidden",
        status: 403
    }
    render json: {errors: [errorObject]}, status: :forbidden
  end

end

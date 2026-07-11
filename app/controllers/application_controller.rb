class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do
    render json: { errors: [ "Not found" ] }, status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render json: { errors: [ exception.message ] }, status: :bad_request
  end
end

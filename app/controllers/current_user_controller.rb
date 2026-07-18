class CurrentUserController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: { user: { id: current_user.id, email: current_user.email, admin: current_user.admin } }
  end
end

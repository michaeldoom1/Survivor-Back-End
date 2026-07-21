class CurrentUserController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: { user: user_json(current_user) }
  end

  def update
    if current_user.update(profile_params)
      render json: { user: user_json(current_user) }
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def user_json(user)
    {
      id: user.id,
      email: user.email,
      admin: user.admin,
      username: user.username,
      first_name: user.first_name,
      last_name: user.last_name
    }
  end

  def profile_params
    params.require(:user).permit(:username, :first_name, :last_name)
  end
end

class UserGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_owned_group, only: [ :update, :destroy ]

  def index
    groups = UserGroup.visible_to(current_user).includes(:owner, :members).order(:name)
    render json: groups.map { |group| group.as_json_for(current_user) }
  end

  def create
    group = current_user.owned_user_groups.new(name: user_group_params[:name])
    group.members = members_from_params
    if group.save
      render json: group.as_json_for(current_user), status: :created
    else
      render json: { errors: group.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    @group.name = user_group_params[:name] if user_group_params.key?(:name)
    @group.members = members_from_params if user_group_params.key?(:member_ids)
    if @group.save
      render json: @group.as_json_for(current_user)
    else
      render json: { errors: @group.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @group.destroy
    head :no_content
  end

  private

  # Members can see a group but only its owner may change it. Anyone else
  # gets a 404 rather than a 403 so group ids don't leak.
  def set_owned_group
    @group = current_user.owned_user_groups.find(params[:id])
  end

  def members_from_params
    User.where(id: Array(user_group_params[:member_ids]))
  end

  def user_group_params
    params.require(:user_group).permit(:name, member_ids: [])
  end
end

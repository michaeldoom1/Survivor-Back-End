class Users::SessionsController < Devise::SessionsController
  respond_to :json

  # Devise skips authenticate_user! inside its own controllers unless forced
  # (see Devise::Controllers::Helpers#define_helpers). We need JWT auth to
  # actually run here so DELETE /logout can find and revoke the caller's token.
  prepend_before_action -> { authenticate_user!(force: true) }, only: :destroy

  private

  def respond_with(resource, _opts = {})
    render json: { user: { id: resource.id, email: resource.email } }, status: :ok
  end

  def respond_to_on_destroy(*)
    render json: { message: "Logged out successfully" }, status: :ok
  end
end

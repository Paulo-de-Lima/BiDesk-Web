module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
  end

  # Public helper methods that can be accessed from controllers and views
  def current_admin
    @current_admin ||= Admin.find_by(id: session[:admin_id]) if session[:admin_id]
  end

  def authenticated?
    current_admin.present?
  end

  private

  # Redirects to the login page when the user is not authenticated.
  def require_authentication
    redirect_to login_path unless authenticated?
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user
  # before_action :require_login
  # skip_before_action :require_login, only: [:create]

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def require_login
    if current_user.nil?
      flash[:erro] = "You must be logged in o view this section"
      redirect_to root_path
    end
  end

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new('Not Found')
  end

  private
  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end
end

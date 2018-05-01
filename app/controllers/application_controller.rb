class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new('Not Found')
  end

  def require_login
    if !@login_user
      flash[:alert] = "You need to be logged in to view that content."
      redirect_to root_path
    end
  end

private
  def find_user
    @login_user ||= User.find_by(id: session[:user_id])
  end
end

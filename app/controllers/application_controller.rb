class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user
  before_action :require_login
  skip_before_action :require_login, only: [:login_form, :create]

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new('Not Found')
  end

  def require_login
    redirect_to root_path, status: :bad_request if session[:user_id].nil?
    flash[:error] = "Log in to see that"
  end


private
  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end

  end
end

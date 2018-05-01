class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user, except: [:root, :login, :upvote]

  before_action :find_user_no_error, only: [:upvote]

  def render_404
     raise ActionController::RoutingError.new('Not Found')
  end

private
  def find_user
    # @login_user = User.find_by(id: session[:user_id])
    find_user_no_error
    render_404 unless @login_user
  end

  def find_user_no_error
    @login_user = User.find_by(id: session[:user_id])
  end

end

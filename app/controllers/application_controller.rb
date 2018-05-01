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

  # def require_login
  #   if @login_user.nil?
  #   # if current_user.nil?
  #     flash[:error] = "You must be logged in to view this section"
  #     redirect_to session_path
  #   end
  # end


  # # Check that the user is logged in, and send back
  # # an error if they are not
  # # Store the looked-up user in @user in case
  # # someone wants to use it later.
  # # We write this method here so it will be available
  # # in _all_ controllers
  # def require_login
  #   @user = User.find_by(id: session[:user_id])
  #   head :unauthorized unless @user
  # end


end

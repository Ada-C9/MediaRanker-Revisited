class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user, except: [:root, :login]

  def render_404
     raise ActionController::RoutingError.new('Not Found')
  end

private
  def find_user
    puts "hellooooooo*************"
    @login_user = User.find_by(id: session[:user_id])
    puts @login_user.inspect
    render_404 unless @login_user
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

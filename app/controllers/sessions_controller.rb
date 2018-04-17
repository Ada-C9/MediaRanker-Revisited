class SessionsController < ApplicationController
  def login_form
  end

  def create
    auth_hash = request.env['omniauth.auth']

    if auth_hash['uid']
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')

      if @user.nil?

        @user = User.get_from_github(auth_hash)

      else
        flash[:status] = :success
        flash[:result_text] = "Logged in successfully"

      end
      session[:user_id] = @user.id

    else

      flash[:result_text] = "Could not log in"

    end
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
    
  end
end

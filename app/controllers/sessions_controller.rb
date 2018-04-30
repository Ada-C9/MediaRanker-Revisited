class SessionsController < ApplicationController


  def create
    auth_hash = request.env['omniauth.auth']

    if auth_hash[:uid]
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user.nil?
        @user = User.login(auth_hash)
      end
      session[:user_id] = @user.id
      flash[:success] = "User #{@user.username} successfully logged in"
      redirect_to root_path
    else
      flash[:status] = :failure
      flash[:result_text] = "Could not log in"
      flash[:messages] = user.errors.messages
      redirect_to root_path
    end
  end

  def logout
    if session[:user_id]
      session.delete(:user_id)
      flash[:result_text] = "Successfully logged out"
      redirect_to root_path
    end
  end

end

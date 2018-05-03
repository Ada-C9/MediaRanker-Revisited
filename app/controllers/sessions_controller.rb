class SessionsController < ApplicationController


  def create
    auth_hash = request.env['omniauth.auth']
    if auth_hash['uid']
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user.nil?
        @user = User.add_user(auth_hash)
        if @user.save
          successful_login
        else
          unsuccessful_login
        end
      else
        successful_login
      end
    else
      unsuccessful_login
    end
  end

  def successful_login
    @user = User.find(session[:user_id])
    flash[:success] = "Logged in successfully"
    redirect_to root_path
  end

  def unsuccessful_login
    flash[:error] = "Could not log in"
    redirect_to root_path
  end

  def destroy
   session[:user_id] = nil
   flash[:success] = "Successfully logged out!"

   redirect_to root_path
 end
end

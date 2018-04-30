class SessionsController < ApplicationController

  def create
    auth_hash = request.env['omniauth.auth']
    # raise
    if auth_hash[:uid]
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user.nil?
        @user = User.build_from_github(auth_hash)
        successful_save = @user.save
        if successful_save
          flash[:status] = :success
          flash[:result_text] = "Successful first login!"
        else
          flash[:status] = :failure
          flash[:result_text] = "An error occurred during User creation."
          flash[:messages] = @user.errors.messages
        end
      else
        flash[:status] = :success
        flash[:result_text] = "Logged in successfully"
        @user.save
      end
      session[:user_id] = @user.id
      session_test = session[:user_id]
    else
      flash[:status] = :failure
      flash[:result_text] = "Logging in through Github not successful"
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

class SessionsController < ApplicationController

  before_action :require_login, except: [:login]

  def login
    auth_hash = request.env['omniauth.auth']

    if auth_hash[:uid]
      @user = User.find_by(uid: auth_hash[:uid], provider: params[:provider])

      if @user.nil?

        @user = User.get_from_github(auth_hash)
        successfull_save = @user.save

        if successfull_save
          flash[:status] = :success
          flash[:result_text] = "Logged in new user successfully"
          session[:user_id] = @user.id

          redirect_to root_path
        else
          flash.now[:status] = :failure
          flash[:result_text] = "Could not log in"
          flash.now[:messages] = user.errors.messages
          redirect_back fallback_location: auth_callback_path
        end

      else
        session[:user_id] = @user.id
        flash[:status] = :success
        flash[:result_text] = "Logged in existing user successfully"
        redirect_to root_path
      end
    else
      flash.now[:status] = :failure
      flash[:error] = "Logging in through GitHub not successful"
      redirect_back fallback_location: root_path
    end

  end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end


  private

  def user_params
    params.require(:user).permit(:name)
  end
end

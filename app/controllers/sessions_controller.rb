require 'pry'
class SessionsController < ApplicationController
  def create
    auth_hash = request.env['omniauth.auth']
    #if uid is valid

    if auth_hash[:uid]
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')


      if @user.nil?
        # It's a new user
        # we need to make user
        @user = User.build_from_github(auth_hash)
        successful_save = @user.save
        if successful_save
          flash[:success] = "Logged in Successfully"
          session[:user_id] = @user.id

          redirect_to root_path
        else
          flash[:error] = "Some error happened in User creation"
          redirect_to root_path
        end
      else
        flash[:success] = "Logged in successfully"
        session[:user_id] = @user.id

        redirect_to root_path

      end

    else
      flash[:error] = "Logging in through GitHub not successful"
      redirect_to root_path
    end
  end

  def new
    @user = User.new
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = "Successfully logged out"
    redirect_to root_path
  end


  private

  def user_params
    params.require(:user).permit(:name)
  end

end

class SessionsController < ApplicationController
  def login_form
  end

  def create
    auth_hash = request.env['omniauth.auth']

    if auth_hash['uid']
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')

      if @user.nil?

        @user = User.get_from_github(auth_hash)
        successfull_save = @user.save

        if successfull_save
          flash[:status] = :success
          flash[:result_text] = "Logged in successfully"
          session[:user_id] = @user.id

          redirect_to root_path
        else
          flash[:result_text] = "Could not log in"
          redirect_to root_path

        end

      else

        flash[:status] = :success
        flash[:result_text] = "Logged in successfully"
        session[:user_id] = @user.id
        redirect_to root_path
      end
    else
      flash[:error] = "Logging in through GitHub not successful"
      redirect_to root_path
    end

  end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path

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

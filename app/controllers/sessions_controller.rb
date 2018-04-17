class SessionsController < ApplicationController
  def login_form
  end

  def login
    auth_hash = request.env['omniauth.auth']

    if auth_hash[:uid] # if the auth_hash has a uid
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user #the user already exists
        session[:user_id] = @user.id
        flash[:status] = :success
        flash[:result_text] = "Existing user #{@user.username} logged in successfully"
      else # new user
        @user = User.new(
          provider: auth_hash[:provider],
          uid: auth_hash[:uid],
          email: auth_hash[:info][:email],
          username: auth_hash[:info][:nickname]
        )
        if @user.save # successful new login
          session[:user_id] = @user.id
          flash[:status] = :success
          flash[:result_text] = "New user #{@user.username} logged in successfully"
        else # unsuccessful login
          flash.now[:status] = :failure
          flash.now[:result_text] = "Could not log in"
          flash.now[:messages] = user.errors.messages
          render "login_form", status: :bad_request
        end
      end
    else # github login not succesful
      flash.now[:result_text] = "Logging in through GitHub not successful"
      render "login_form", status: :bad_request
    end

    # username = params[:username]
    # if username and user = User.find_by(username: username)
    #   session[:user_id] = user.id
    #   flash[:status] = :success
    #   flash[:result_text] = "Successfully logged in as existing user #{user.username}"
    # else
    #   user = User.new(username: username)
    #   if user.save
    #     session[:user_id] = user.id
    #     flash[:status] = :success
    #     flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
    #   else
    #     flash.now[:status] = :failure
    #     flash.now[:result_text] = "Could not log in"
    #     flash.now[:messages] = user.errors.messages
    #     render "login_form", status: :bad_request
    #     return
    #   end
    # end
    redirect_to root_path
  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end

class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:login]

  def login_form
  end

  def login
    auth_hash = request.env['omniauth.auth']

    if auth_hash[:uid]
      @user = User.find_by(uid: auth_hash[:uid], provider: "github")
      if @user
        session[:user_id] = @user.id
        flash[:status] = :success
        flash[:result_text] = "Successfully logged in as existing user #{@user.username}"
      else
        @user = User.new(
          username: auth_hash[:info][:nickname],
          uid: auth_hash[:uid],
          email: auth_hash[:info][:email],
          provider: auth_hash[:provider]
        )
        if @user.save
          session[:user_id] = @user.id
          flash[:status] = :success
          flash[:result_text] = "Successfully created new user #{@user.username} with ID #{@user.id}"
        else
          flash.now[:status] = :failure
          flash.now[:result_text] = "Could not log in"
          flash.now[:messages] = user.errors.messages
          render "login_form", status: :bad_request
          return
        end
      end
    else
      flash.now[:result_text] = "Could not log in"
      render "login_form", status: :bad_request
    end
    redirect_to root_path
  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end

class SessionsController < ApplicationController
  skip_before_action :require_login

  def login
    auth_hash = request.env['omniauth.auth']

    username = auth_hash[:info][:name]
    if username and user = User.find_by(email: auth_hash[:info][:email])
      session[:user_id] = user.id
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as existing user #{user.username}"
    else
      user = User.new(
        username: username,
        uid: auth_hash[:uid],
        email: auth_hash[:info][:email],
        provider: auth_hash[:provider]
      )
      if user.save
        session[:user_id] = user.id
        flash[:status] = :success
        flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
      else
        flash.now[:status] = :failure
        flash.now[:result_text] = "Could not log in"
        flash.now[:messages] = user.errors.messages
        render "login_form", status: :bad_request
        return
      end
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

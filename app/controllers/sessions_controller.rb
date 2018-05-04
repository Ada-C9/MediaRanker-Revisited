class SessionsController < ApplicationController

  def create
    auth_hash = request.env['omniauth.auth']

    if auth_hash['uid']
      user = User.get_user(auth_hash)
      if user.nil?
        flash[:result_text] = 'Could not log in'
        flash[:messages] = user.errors.messages
        redirect_to root_path
        return
      end
      session[:user_id] = user.id
      flash[:success] = 'Successfully logged in'
    else
      flash[:result_text] = "Could not log in"
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

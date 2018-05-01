class SessionsController < ApplicationController

  before_action :block_guest, except: [:create]

  #Why do I need this?
  def index
    @user = User.find(session[:user_id]) # < recalls the value set in a previous request
  end

  def destroy
    session[:user_id] = nil
    flash[:result_text] = "Successfully logged out!"
    redirect_to root_path
  end

  def create
    auth_hash = request.env['omniauth.auth']

    if auth_hash['uid']
      user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if user.nil?
        user = User.build_from_github(auth_hash)
        flash[:result_text] = "Logged in successfully and created new Media Ranker account"
      else
        flash[:result_text] = "Logged in successfully"
      end
      session[:user_id] = user.id
    else
      flash[:error] = "Could not log in"
    end
    redirect_to root_path
  end

end

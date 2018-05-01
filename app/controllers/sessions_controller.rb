class SessionsController < ApplicationController
  def login_form
  end

  def index
    @user = User.find(session[:user_id]) # < recalls the value set in a previous request
  end

  def new
    @user = User.new
  end

  def create
    auth_hash = request.env['omniauth.auth']

    if auth_hash['uid']
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user.nil?
        # User doesn't match anything in the DB
        # Attempt to create a new user
        @user = User.new( name: auth_hash['info']['name'], email: auth_hash['info']['email'], uid: auth_hash['uid'], provider: auth_hash['provider'])
        if @user.save
          # saved successfully
          session[:user_id] = @user.id
          flash[:success] = "Logged in successfully"
          redirect_to root_path
        else
          # not saved successfully
          flash[:error] = "Could not log in"
          redirect_to root_path
        end
      else
        session[:user_id] = @user.id
        flash[:success] = "Logged in successfully"
        redirect_to root_path
      end
    else
      flash[:error] = "Could not log in"
      redirect_to root_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = "Successfully logged out!"

    redirect_to root_path
  end
end

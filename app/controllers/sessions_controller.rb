class SessionsController < ApplicationController

  def new ; end

  def create
    auth_hash = request.env['omniauth.auth']

    if session[:user_id] != nil
      flash[:failure] = "Could not log in, an user is already logged in"
      redirect_to root_path
    end

  if auth_hash['uid']
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')

      if @user.nil?
        @user = User.new(
          username: auth_hash['info']['name'],
          email: auth_hash['info']['email'],
          uid: auth_hash['uid'],
          provider: auth_hash['provider'])


          if @user.save
            session[:user_id] = @user.id
            flash[:success] = "Logged in!"
            redirect_to root_path
          else
            flash[:failure] = "Could not log in, user could not be created"
            redirect_to root_path
          end

        else
          session[:user_id] = @user.id
          flash[:success] = "You are logged in, welcome back!"
          redirect_to root_path
        end

      else
        flash[:error] = "You could not login"
        redirect_to root_path
      end
    end

    def destroy
      session.delete(:user_id)
      flash[:success] = "Logged out successfully"
      redirect_to root_path
    end

  end

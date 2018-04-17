class SessionsController < ApplicationController
  # def login_form
  # end

  def create
    auth_hash = request.env['omniauth.auth']
    if auth_hash['uid']
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user.nil?
        @user = User.build_from_github(auth_hash)
        if @user.save
          session[:user_id] = @user.id
          flash[:status] = :success
          flash[:result_text] = "Successfully created new user #{@user.username} with ID #{@user.id}"
          redirect_to root_path
        else
          flash[:status] = :failure
          flash[:result_text] = "Could not create user"
          redirect_to root_path
        end
      else
        session[:user_id] = @user.id
        flash[:status] = :success
        flash[:result_text] = "Successfully logged in as existing user #{@user.username}"
        redirect_to root_path
      end
    else
      flash.now[:status] = :failure
      flash.now[:result_text] = "Could not log in"
      flash.now[:messages] = @user.errors.messages
      render "login_form", status: :bad_request
      return
    end
  end

  class SessionsController < ApplicationController
    def destroy
      session[:user_id] = nil
      flash[:status] = :success
      flash[:messages] = "Successfully logged out!"

      redirect_to root_path
    end
  end

  # def login
  #   username = params[:username]
  #   if username and user = User.find_by(username: username)
  #     session[:user_id] = user.id
  #     flash[:status] = :success
  #     flash[:result_text] = "Successfully logged in as existing user #{user.username}"
  #   else
  #     user = User.new(username: username)
  #     if user.save
  #       session[:user_id] = user.id
  #       flash[:status] = :success
  #       flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
  #     else
  #       flash.now[:status] = :failure
  #       flash.now[:result_text] = "Could not log in"
  #       flash.now[:messages] = user.errors.messages
  #       render "login_form", status: :bad_request
  #       return
  #     end
  #   end
  #   redirect_to root_path
  # end

  # def logout
  #   session[:user_id] = nil
  #   flash[:status] = :success
  #   flash[:result_text] = "Successfully logged out"
  #   redirect_to root_path
  # end
end

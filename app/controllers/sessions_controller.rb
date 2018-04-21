class SessionsController < ApplicationController
  def login_form
  end

  def login
    auth_hash = request.env['omniauth.auth']

    if auth_hash[:uid]
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      # @user = User.find_by(uid: auth_hash[:uid], provider: params[:provider])

      if @user.nil?
        @user = User.build_from_github(auth_hash)
        successful_save = @user.save

        if successful_save
          session[:user_id] = @user.id
          flash[:status] = :success
          flash[:result_text] = "Successfully created new user #{@user.username} with ID #{@user.id}"
        else
          flash.now[:status] = :failure
          flash.now[:result_text] = "Could not log in"
          flash.now[:messages] = user.errors.messages
        end

      else
        session[:user_id] = @user.id
        flash[:status] = :success
        flash[:result_text] = "Successfully logged in as existing user #{@user.username}"
      end

    else
      flash.now[:status] = :failure
      flash[:result_text] = "Logging in through GitHub not successful"
    end

    redirect_to root_path

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
    # redirect_to root_path
  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end

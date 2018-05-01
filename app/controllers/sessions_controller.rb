class SessionsController < ApplicationController

  def create
    auth_hash = request.env['omniauth.auth']
    if auth_hash['uid']
      @user = User.find_by(uid: auth_hash['uid'])
      if @user.nil?
        create_new_user
      else
        flash[:status] = :success
        flash[:result_text] = "Logged in successfully, welcome back #{@user.username}"
      end
      session[:user_id] = @user.id
    else
      flash[:status] = :failure
      flash[:result_text] = "Log in has failed"
    end
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "You've logged out"
    redirect_to root_path
  end

  private
  def create_new_user
      auth_hash = request.env['omniauth.auth']
      @user = User.new(username: auth_hash['info']['nickname'], email: auth_hash['info']['email'], uid: auth_hash['uid'], provider: 'Github')
      if @user.save
        flash[:status] = :success
        flash[:result_text] = "Your account has been generated #{@user.username}!"
      else
        flash[:status] = :failure
        flash[:result_text] = "Something has gone wrong in the account generation process."
      end
  end
  # def logout
  #   session[:user_id] = nil
  #   flash[:status] = :success
  #   flash[:result_text] = "Successfully logged out"
  #   redirect_to root_path
  # end

  # def login_form
  # end

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
  #
  #       flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
  #     else
  #
  #       flash.now[:status] = :failure
  #       flash.now[:result_text] = "Could not log in"
  #       flash.now[:messages] = user.errors.messages
  #
  #       render "login_form", status: :bad_request
  #       return
  #     end
  #   end
  #   redirect_to root_path
  # end



end

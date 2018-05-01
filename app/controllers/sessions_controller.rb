class SessionsController < ApplicationController
  def login_form
  end

  def create
    auth_hash = request.env['omniauth.auth']


    if auth_hash['uid']
      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')
      if @user.nil?
        @user = User.new(
          username: auth_hash[:info][:name],
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
          flash.now[:result_text] = "Could not create new user."
          flash.now[:messages] = user.errors.messages
          render "login_form", status: :bad_request
          return
        end

      else
        session[:user_id] = @user.id
        flash[:status] = :success
        flash[:result_text] = "Successfully logged in as existing user #{@user.username}"
      end

    else
      flash.now[:status] = :failure
      flash.now[:result_text] = "Authentication failed."
      render "login_form", status: :bad_request
      return
    end

    redirect_to root_path

  end # create

  def logout
    session.delete(:user_id)
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end # logout

end # SessionsController

class SessionsController < ApplicationController
  # def login_form
  # end

  def login
    auth_hash = request.env['omniauth.auth']

    if auth_hash[:uid]

      @user = User.find_by(uid: auth_hash[:uid], provider: 'github')

      if @user.nil?
        @user = User.info_from_github(auth_hash)

        flash[:status] = :success
        flash[:result_text] = "Successfully created new user #{@user.username} with ID #{@user.id}"
      end

      session[:user_id] = @user.id
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as existing user #{user.username}"
    else
        flash.now[:status] = :failure
        flash.now[:result_text] = "Could not log in"
        flash.now[:messages] = user.errors.messages
        render :root, status: :bad_request
        return
      end
    end
    redirect_to root_path
  end

  def logout
    if session[:user_id]
      session[:user_id] = nil
      flash[:status] = :success
      flash[:result_text] = "Successfully logged out"
      redirect_to root_path
    end
  end

end

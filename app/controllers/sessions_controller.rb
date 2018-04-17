class SessionsController < ApplicationController
  def login_form
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

  def create
    #omnia passing out information from the provider

    auth_hash = request.env['omniauth.auth']

    if auth_hash['uid']
      @username = User.find_by(uid: auth_hash[:uid], provider: 'github')

      if @user.nil?
        # User doesn't match anything in the DB
        # Attempt to create a new user
        get_info_from_authhash

          if @user.save
            #saved successfully
            session[:user_id]= @user.id
            flash[:sucess] = "Logged in successfully"
            redirect_to root_path
          else
            #not saved successfully
            flash[:error] = "Could not log in"
            redirect_to root_path
          end
        else
          session[:user_id]= @user.id
          flash[:success] = "Logged in successfully"
          redirect_to root_path
        end
      else
        flash[:error] = "Could not log in"
        redirect_to root_path
      end

      #
      # author = Author.find_by(name: params[:name])
      #
      # if author
      #   session[:author_id] = author.id
      #   flash[:success] = "#{ author.name } is successfully logged in"
      #   redirect_to root_path
      # end
    end
  end



  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end

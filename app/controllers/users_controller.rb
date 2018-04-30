class UsersController < ApplicationController

 before_action :require_login

  def index
    @users = User.all
  end

  # def create
  #   user_id = params[:user][:id]
  #   if user_id
  #     redirect_to root_path
  #   else
  #     flash[:status] = :failure
  #     flash[:result_text] = "Could not create a new user ID."
  #     # flash[:messages] = @user.errors.messages
  #   end
  # end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end



  private

  def user_params
    params.require(:user).permit(:username, :email, :uid, :provider, :term )
  end
end

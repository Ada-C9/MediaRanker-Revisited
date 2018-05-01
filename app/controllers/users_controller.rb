class UsersController < ApplicationController
  def index
    @users = User.all
    render :success unless @users
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end
end

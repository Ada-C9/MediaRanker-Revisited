class UsersController < ApplicationController
  # def index
  #   @users = User.all
  # end
  #
  # def show
  #   @user = User.find_by(id: params[:id])
  #   render_404 unless @user
  # end
  before_action :find_user

  def show
    @user = User.find_by(id: params[:id])
  end

  def index
    @users = User.all
  end
end

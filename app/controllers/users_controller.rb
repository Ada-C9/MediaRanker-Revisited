class UsersController < ApplicationController
before_action :check_user, only: [:show, :index]
  def index
      @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  private
  def check_user
    unless @login_user
      flash[:status] = :failure
      flash[:result_text] = "You must log in to see this content"
      redirect_to root_path
    end
  end
end

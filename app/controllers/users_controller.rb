class UsersController < ApplicationController
  def index
    if @login_user.nil?
      render_404
    else
      @users = User.all
    end
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @login_user
  end
end

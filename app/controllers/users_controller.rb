class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    # should be done in application 
    # @user = User.find_by(id: params[:id])
    # render_404 unless @user
  end
end

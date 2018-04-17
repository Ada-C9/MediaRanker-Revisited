class UsersController < ApplicationController

  before_action :logged_in
  
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end
end

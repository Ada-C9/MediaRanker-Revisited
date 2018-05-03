class UsersController < ApplicationController

  before_action :require_login, except: [:root]

  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end
end

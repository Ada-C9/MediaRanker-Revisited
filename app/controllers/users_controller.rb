class UsersController < ApplicationController
  before_action :logged_in?, except: [:root]

  def index
    logged_in? ? @users = User.all : must_login_mssg()
  end

  def show
    if logged_in?
      @user = User.find_by(id: params[:id])
      render_404 unless @user
    else
      must_login_mssg()
    end
  end
end

class SessionsController < ApplicationController
  before_action :user_must_logged_in, only: [:destroy]
  before_action :user_not_logged_in, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      redirect_to new_trigonometry_path
      flash[:success] = "Welcome back, #{ user.name }"
    else
      flash[:danger] = "Your email or password is invalid"
      render "new"
    end
  end

  def destroy
    log_out
    redirect_to login_path
    flash[:success] = "Logout successfully"
  end
end

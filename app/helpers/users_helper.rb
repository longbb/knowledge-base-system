module UsersHelper
  def user_must_logged_in
    unless current_user.present?
      redirect_to login_path
      flash[:warning] = "You must login"
    end
  end

  def user_not_logged_in
    if current_user.present?
      redirect_to user_path(current_user)
      flash[:warning] = "You have logged in"
    end
  end

  def user_must_be_current_user
    @user = User.find params[:id]
    if current_user.present?
      unless current_user == @user
        redirect_to login_path
        flash[:warning] = "Permission denied!"
      end
    end
  end

  def is_current_user?
    @user = User.find params[:id]
    return @user.id == current_user.id
  end
end

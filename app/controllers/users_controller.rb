class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    if @user = find_user
      update_user!
    else
      create_user!
    end
  end

  private

  def create_user!
    @user = User.new(user_params)

    if @user.save
      flash.now[:message] = 'success, record created!'

      render_new_on_success
    else
      render_new_on_error
    end
  end

  def update_user!
    if @user.update(user_params)
      flash.now[:message] = 'success, record updated!'

      render_new_on_success
    else
      render_new_on_error
    end
  end

  def find_user
    user_email_and_password = user_params.select do |key, _|
      ['mealpass_email', 'mealpass_password'].include?(key)
    end

    User.find_by(user_email_and_password)
  end

  def render_new_on_error
    flash.now[:error] = 'oh no, check the fields'

    render :new
  end

  def render_new_on_success
    @user = User.new

    render :new
  end

  def user_params
    params.require(:user).permit(:mealpass_email, :mealpass_password, order_days: [])
  end
end

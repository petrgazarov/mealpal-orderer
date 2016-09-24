class UsersController < ApplicationController
  def new
    @user = User.new(address: '22 West 19th Street, New York, NY, United States')
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
      flash[:message] = "success, record created!"

      redirect_to root_path
    else
      render_new_on_error
    end
  end

  def update_user!
    @user.order_days.destroy_all

    if @user.update(user_params)
      flash[:message] = 'success, record updated!'

      redirect_to root_path
    else
      render_new_on_error
    end
  end

  def find_user
    user_email_and_password = user_params.select do |key, _|
      ['mealpal_email', 'mealpal_password'].include?(key)
    end

    User.find_by(user_email_and_password)
  end

  def render_new_on_error
    flash.now[:error] = 'oh no, check the fields'

    render :new
  end

  def user_params
    params
      .require(:user)
      .permit(:mealpal_email, :mealpal_password, :address, order_days_attributes: [:scheduled_to_order, :whitelist, :blacklist, :week_day_number])
  end
end

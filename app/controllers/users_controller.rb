class UsersController < ApplicationController
  before_action :redirect_signed_out_user, only: [:show, :edit, :update]

  def new
    log_out! if current_user

    @user = User.new(address: '22 West 19th Street, New York, NY, United States')
  end

  def create
    @user = User.new(user_params)

    if @user.save
      log_in!(@user)

      flash[:message] = "success, record created!"

      redirect_to user_path(@user)
    else
      flash.now[:error] = 'oh no, check the fields'

      render :new
    end
  end

  def show
    if params[:id].to_i != current_user.id
      redirect_to user_path(current_user)
    end

    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      flash[:message] = 'success, record updated!'

      redirect_to user_path(@user)
    else
      flash.now[:error] = 'oh no, check the fields'

      render :edit
    end
  end

  private

  def user_params
    params
      .require(:user)
      .permit(:mealpal_email, :mealpal_password, :address, order_days_attributes: [:id, :scheduled_to_order, :whitelist, :blacklist, :week_day_number])
  end
end

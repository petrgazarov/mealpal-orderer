class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:message] = 'success, record created!'

      @user = User.new
      render :new
    else
      flash[:message] = 'oh no, check the fields'

      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:mealpass_email, :mealpass_password)
  end
end

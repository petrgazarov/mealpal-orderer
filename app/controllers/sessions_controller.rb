class SessionsController < ApplicationController
  before_action :redirect_signed_out_user, only: [:destroy]
  before_action :redirect_current_user, except: [:destroy]

  def new
    @user = User.new
  end

  def create
    @user = User.find_by_credentials(mealpal_email, mealpal_password)

    if @user
      log_in!(@user)

      redirect_to user_path(@user)
    else
      flash.now[:error] = "Oops, can't find that user!"

      @user = User.new(mealpal_email: mealpal_email)
      render :new
    end
  end

  def destroy
    current_user.reset_session_token!

    session[:session_token] = nil

    redirect_to root_url
  end

  private

  def mealpal_email
    params[:user][:mealpal_email]
  end

  def mealpal_password
    params[:user][:mealpal_password]
  end
end

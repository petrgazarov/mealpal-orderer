class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find_by(session_token: session[:session_token])
  end

  def logged_in?
    !!current_user
  end

  def log_in!(user)
    user.reset_session_token!

    session[:session_token] = user.session_token
  end

  def log_out!
    current_user.reset_session_token!

    session[:session_token] = nil

    current_user.reload
  end

  def redirect_current_user
    redirect_to user_path(current_user) if current_user
  end

  def redirect_signed_out_user
    redirect_to root_path unless current_user
  end
end

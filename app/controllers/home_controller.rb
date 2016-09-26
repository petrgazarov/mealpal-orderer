class HomeController < ApplicationController
  before_action :redirect_current_user

  def index
  end
end

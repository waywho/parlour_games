class SessionsController < ApplicationController
  def new
  end

  def create
    redirect_to root_path
  end

  def destroy
    redirect_to root_path
  end
end

module Api
  class UsersController < ApplicationController
    before_action :authenticate_user, except: [:create]
    before_action :set_user, only: [:show, :update, :destroy]

    # GET /users
    def index
      if params[:search].present?
        @users = User.where('lower(name) LIKE ?', "%#{params[:search].downcase}%")
        logger.debug("Number of users found: #{@users.length}")
      else
        @users = User.all
      end
      render json: @users, only: [:id, :name, :email, :avatar]
    end

    # GET /users/1
    def show
      render json: @user
    end

    # POST /users
    def create
      @user = User.new(user_params)

      if @user.save
        render json: @user, only: [:id, :name, :email, :avatar] , status: :created
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /users/1
    def update
      if @user.update(user_params)
        render json: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    # DELETE /users/1
    def destroy
      @user.destroy
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation, :admin, :avatar)
      end
  end
end
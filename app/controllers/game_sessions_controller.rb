class GameSessionsController < ApplicationController
  before_action :set_game_session, only: [:show, :update, :destroy]

  # GET /game_sessions
  def index
    @game_sessions = GameSession.all

    render json: @game_sessions
  end

  # GET /game_sessions/1
  def show
    render json: @game_session
  end

  # POST /game_sessions
  def create
    @game_session = GameSession.new(game_session_params)

    if @game_session.save
      render json: @game_session, status: :created, location: @game_session
    else
      render json: @game_session.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /game_sessions/1
  def update
    if @game_session.update(game_session_params)
      render json: @game_session
    else
      render json: @game_session.errors, status: :unprocessable_entity
    end
  end

  # DELETE /game_sessions/1
  def destroy
    @game_session.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game_session
      @game_session = GameSession.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def game_session_params
      params.require(:game_session).permit(:name, :description, :rules, :avatar)
    end
end

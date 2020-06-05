module Api
  class GamesController < ApplicationController
    before_action :set_game, only: [:show, :update, :destroy, :setup]

    # GET /games
    def index
      logger.debug "User IP: #{request.remote_ip}"
      if params[:type] == 'my'
        @games = current_user.games
        logger.debug "My games: #{@games.length}"
      else
        @games = Game.all
      end

      render json: @games, include: {chatroom: {}, teams: {}, users: { only: :name }, players: { only: :name }}, except: [:user_id, :team_id]
    end

    # GET /games/1
    def show
      game_json_response
    end

    # POST /games
    def create
      @game = game_params[:name].constantize.create
      @game.game_sessions.build(playerable: current_user, host: true, invitation_accepted: true)
      # if game_params[:user_ids].present?
      #   @game.user_ids = game_params[:user_ids]
      # end
      logger.debug "Game created: #{@game.inspect}"

      if @game.save
        # @game.game_sessions&.each do |session|
        #   GameSessionRelayJob.perform_later(session)
        # end
        game_json_response(:created)
      else
        render json: @game.errors, status: :unprocessable_entity
      end
    end

    def setup
      if game_params[:team_mode].present? && game_params[:team_mode]
        teams = []
        game_params[:team_numbers].to_i.times { @game.teams.build }
        logger.debug "Teams to create #{game_params[:team][:numbers]}"
      else
        teams = game_params[:teams]
      end
      
      GameSetupRelayJob.perform_later({game: @game, teams: teams.to_json})
      render json: @game.teams, status: :ok
    end

    # PATCH/PUT /games/1
    def update
      begin
        @game.with_lock do
          @game.update(game_params)
        end
      
        if game_params[:team_mode] && @game.teams.empty?
          logger.debug "Teams to create #{team_params[:team][:numbers]}"
          team_params[:team][:numbers].to_i.times { @game.teams.create }
        elsif game_params[:team_mode].present? && game_params[:team_mode] == false
          @game.teams.destroy_all
        end
        GameSetupRelayJob.perform_later(@game)
        game_json_response

      rescue StandardError => ex
        render json: @game.errors, status: :unprocessable_entity
      end
    end

    # DELETE /games/1
    def destroy
      @game.destroy
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_game
        @game = Game.find(params[:id])
      end

      def game_json_response(status=:ok)
        render json: @game, include: {chatroom: {}, teams: { include: [:game_sessions], except: [:game_id, :updated_at]}, game_sessions: { methods: [:team_name, :class_name, :name], except: [:game_id, :created_at, :updated_at] }}, status: status
      end

      # Only allow a trusted parameter "white list" through.
      def game_params
        params.require(:game).permit(:id, :name, :team_mode, :score, :game_sessions, :started, :ended, set: {}, user_ids: [], player_ids: [], teams_attributes: [:id, :name, :order, game_session_ids: []], team: {})
      end

      def team_params
        params.permit(team: [:numbers])
      end
  end
end

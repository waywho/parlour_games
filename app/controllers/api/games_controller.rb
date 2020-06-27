module Api
  class GamesController < ApplicationController
    before_action :set_game, only: [:show, :update, :destroy, :setup]
    before_action :authenticate_user, only: [:create, :destroy]
    # GET /games
    def index
      logger.debug "User IP: #{request.remote_ip}"
      if params[:type] == 'my'
        @games = current_user.games
        logger.debug "My games: #{@games.length}"
      else
        @games = Game.all
      end

      render json: @games, include: {chatroom: {}, teams: { include: [:game_sessions], methods: [:scores], except: [:game_id, :updated_at]}, game_sessions: { methods: [:team_name, :class_name, :name], except: [:game_id, :created_at, :updated_at] }}
    end

    # GET /games/1
    def show
      game_json_response
    end

    # POST /games
    def create
      begin
      @game = game_params[:name].constantize.create
      @game.game_sessions.create(playerable: current_user, host: true, invitation_accepted: true)
      logger.debug "Game created: #{@game.inspect}"

      if @game.persisted?
        game_json_response(:created)
      end
      rescue StandardError => ex
        render json: ex, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /games/1
    def update
      begin
        @game.with_lock do
          @game.update(game_params)
        end
      
        if game_params[:team_mode] == true && @game.teams.empty?
          logger.debug "Teams to create #{team_params[:team][:numbers]}"
          team_params[:team][:numbers].to_i.times { Team.create(game: @game)}
        elsif game_params[:team_mode] == false
          
          @game.teams&.each do |team|
            logger.debug "delete sessions associations"
            team.game_sessions.clear
          end
          logger.debug "delete teams"
          @game.teams.destroy_all
        end
        GameRelayJob.perform_later(@game)
        game_json_response

      rescue StandardError => ex
        logger.debug "Error updating, #{ex}"
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
        render json: @game, include: {chatroom: {}, teams: { include: [:game_sessions], methods: [:scores], except: [:game_id, :updated_at]}, game_sessions: { methods: [:team_name, :class_name, :name], except: [:game_id, :created_at, :updated_at] }}, status: status
      end

      # Only allow a trusted parameter "white list" through.
      def game_params
        params.require(:game).permit(:id, :name, :team_mode, :started, :ended, set: {}, turn_order: {}, user_ids: [], player_ids: [], teams_attributes: [:id, :name, :order, game_session_ids: [], scores: {}], team: {}, game_sessions_attributes: [:id, scores: {}])
      end

      def team_params
        params.permit(team: [:numbers])
      end
  end
end

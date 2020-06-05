module Api
  class GameSessionsController < ApplicationController
    before_action :set_game_session, only: [:show, :update, :destroy]

    # GET /api/game_sessions
    def index
      if params[:playerable_id].present? && params[:playerable_type].present?
        @game_sessions = GameSession.where(game_id: params[:game_id], playerable_id: params[:playerable_id], playerable_type: params[:playerable_type]).take
        join_update(@game_sessions) if @game_sessions.present?
      elsif params[:search].present?
        @game_sessions = GameSession.where(player_name: params[:search], game_id: params[:game_id]).take
        join_update(@game_sessions) if @game_sessions.present?
      else
        @game_sessions = GameSession.all
      end

      render json: @game_sessions
    end

    # GET /api/game_sessions/1
    def show
      render json: @game_session
    end

    # POST /api/game_sessions
    def create
      # need to secure this method for only authenticated host
      if params[:user_ids].present?
        params[:user_ids].each do |id|
          user = User.find(id)
          @game_session = user.game_sessions.build(game_session_params)
          logger.debug "Game Session initialised #{@game_session.inspect}"
          
          if @game_session.save
            GameSessionRelayJob.perform_later(@game_session)
            render json: @game_session, status: :created
          else
            render json: @game_session.errors, status: :unprocessable_entity
          end
        end
      else
         # player = Player.create(name: params[:player][:name], ip_address: request.remote_ip)
        @game_session = GameSession.new(game_session_params.merge(ip_address: request.remote_ip))
        logger.debug "Game Session initialised #{@game_session.inspect}"
        if @game_session.save
          GameSessionRelayJob.perform_later(@game_session)
          render json: @game_session, status: :created
        else
          render json: @game_session.errors, status: :unprocessable_entity
        end
      end
      


    end

    # PATCH/PUT /api/game_sessions/1
    def update
      if @game_session.update(game_session_params)
        render json: @game_session
      else
        render json: @game_session.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/game_sessions/1
    def destroy
      @game_session.destroy
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_game_session
        @game_session = GameSession.find(params[:id])
      end

      def join_update(game_session)
        game_session.update_attributes(invitation_accepted: true)
      end

      # Only allow a trusted parameter "white list" through.
      def game_session_params
        params.require(:game_session).permit(:playerable_id, :playerable_type, :score, :game_id, :team_id, :host, :invitation_accepted, :player_name)
        # params.fetch(:game_session, {})
      end
  end
end
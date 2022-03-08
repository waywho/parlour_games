module Api
  class ChatroomsController < ApiController
    before_action :authenticate_user, except: [:show]
    before_action :set_chatroom, only: [:show, :join_chat, :leave_chat, :update, :destroy]

    # GET /chatrooms
    def index
      if params[:type] == "my"
        @chatrooms = current_user.chatrooms
      elsif params[:search].present?
        @chatrooms = Chatroom.where('topic LIKE ?', "%#{params[:search]}%")
      else
        @chatrooms = Chatroom.all
      end

      render json: @chatrooms, methods: :user_ids
    end

    # GET /chatrooms/1
    def show
      render json: @chatroom, include: { messages: { include: { speakerable: { only: [:name], methods: [:name] }}, except: [:user_id, :id]} }
    end


    def join_chat
      @chatroom.chatroom_users.where(user_id: current_user.id).first_or_create

      render json: @chatroom
    end

    # POST /chatrooms
    def create
      @chatroom = Chatroom.create(chatroom_params)

      if @chatroom.save
        # ChatroomUser.create(user: current_user, chatroom: @chatroom)
        ChatroomRelayJob.perform_later(@chatroom)
        render json: @chatroom, status: :created
      else
        render json: @chatroom.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /chatrooms/1
    def update
      if @chatroom.update(chatroom_params)
        render json: @chatroom
      else
        render json: @chatroom.errors, status: :unprocessable_entity
      end
    end

    # DELETE /chatrooms/1
    def destroy
      @chatroom.destroy
    end

    def leave_chat
      if chatroom_params[:user_ids].nil?
        user_ids = [current_user.id]
      else
        user_ids = chatroom_params[:user_ids].push(current_user.id)
      end
      @chatroom.chatroom_users.where(user_id: user_ids).destroy_all
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_chatroom
        chat_id = params[:id] || chat_id = params[:chatroom_id]
        @chatroom = Chatroom.find(chat_id)
      end

      # Only allow a trusted parameter "white list" through.
      def chatroom_params
        params.require(:chatroom).permit(:gameaable_id, :chatroom_id, :topic, :public, user_ids: [])
      end
  end
end

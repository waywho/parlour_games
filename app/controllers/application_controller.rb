class ApplicationController < ActionController::API
	include Knock::Authenticable
	
	def authenticate_admin
		current_user.admin?
	end

	def render_token_payload(entity)
		auth_token = Knock::AuthToken.new payload: entity.to_token_payload
      render json: { 'body': auth_token }, status: :created
	end
end

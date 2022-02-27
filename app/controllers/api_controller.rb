class ApiController < ActionController::API
	include Knock::Authenticable
	
	def authenticate_admin
		current_user.admin?
	end

	def render_token_payload(entity, status = :created)
		auth_token = Knock::AuthToken.new payload: entity.to_token_payload
      render json: { 'body': auth_token }, status: status
	end
end

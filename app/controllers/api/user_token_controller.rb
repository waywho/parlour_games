module Api
	class UserTokenController < Knock::AuthTokenController
		skip_before_action :verify_authenticity_token, raise: false

		def create
			if entity.confirmation_sent_at.present? && entity.confirmed_at.blank?
				render json: {
					status: '422',
					title: 'Email account unconfirmed',
					message: 'Your account is not confirmed. We have sent you an email for email confirmation. Please follow the confirmation link.'
				}, status: :unprocessibly_entity
			else
				render json: auth_token, status: :created
			end
		end

		def entity_name
			'User'
		end

	end
end

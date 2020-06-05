require 'jwt'
module ApplicationCable
  class Connection < ActionCable::Connection::Base
  	identified_by :current_user

  	def connect
  		@jwt_token = request.params[:token]
      if @jwt_token.present?
  		  self.current_user = find_verified_user
        logger.add_tags "ActionCable", "User #{current_user.id}"
      end
  		logger.add_tags "ActionCable", "Unauthenticated User"
  	end

  	private
  	
  	attr_reader :jwt_token

  		def find_verified_user
  			payload, = decode_token
  			if verified_user = User.find(payload['sub'])
  				verified_user
  			else
  				reject_unauthorized_connection
  			end
  		end

  		def decoding_key
  			Knock.token_secret_signature_key.call
  		end

  		def decode_token
  			JWT.decode(jwt_token.to_s, decoding_key)
  		end
  end
end

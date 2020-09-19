class UserMailer < ApplicationMailer
	default from: "info@parlourgames.club"

	def confirmation_email
		@user = params[:user]
		mail to: @user.email, subject: "[Parlour Games] Please confirm your email"
	end
end

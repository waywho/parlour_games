class UserMailer < ApplicationMailer
	default from: "info@parlourgames.club"

	def confirmation_email
		@user = params[:user]
		mail to: @user.email, subject: "[Parlour Games] Confirm your email"
	end
end

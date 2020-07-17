class UserMailer < ApplicationMailer
	default from: "info@parlourgames.club"

	def registration(user)
		@user = user

		mail to: @user.email, subject: "[Parlour Games] Confirm your email"

	end
end

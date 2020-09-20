class UserMailer < ApplicationMailer
	default from: "info@parlourgames.club"

	def confirmation_email
		@user = params[:user]
		mail to: @user.email, subject: "[Parlour Games] Please confirm your email"
		@user.update_attribute(:confirmation_sent_at, Time.now)
	end
end

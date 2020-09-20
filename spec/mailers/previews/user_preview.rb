# Preview all emails at http://localhost:3000/rails/mailers/user
class UserPreview < ActionMailer::Preview
	def confirmation_email
		@user = User.find(5)
		UserMailer.with(user: @user).confirmation_email
	end
end

require 'rails_helper'

RSpec.describe User, type: :model do
	it "is valid with valid attributes" do
		user = FactoryBot.build(:user)
		expect(user).to be_valid
	end
  it "is not valid without an eamil" do
  	user = FactoryBot.build(:user, email: nil)
  	expect(user).to_not be_valid
  end
  it "is not valid without a name" do
  	user = FactoryBot.build(:user, name: nil)
  	expect(user).to_not be_valid
  end
  it "is not valid without a password" do
  	user = FactoryBot.build(:user, password: nil)
  	expect(user).to_not be_valid
  end

  describe "Associations" do
  	it { should have_many(:teams) }
  	it { should have_many(:games) }
  	it { should have_many(:fishbowls) }
  	it { should have_many(:game_sessions) }
  	it { should have_many(:messages) }
  	it { should have_many(:chatroom_users) }
  	it { should have_many(:chatrooms) }
  end
end

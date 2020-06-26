require 'rails_helper'

RSpec.describe GameSession, type: :model do
   describe "Associations" do
  	it { should belong_to(:game) }
  	it { should belong_to(:playerable).optional }
  	it { should belong_to(:team).optional }
  	it { should belong_to(:fishbowl).optional }
  	it { should belong_to(:ghost).optional }
  	it { should have_many(:messages) }
  end

  describe "setup_scores" do
  	context "will set up scores according to game type:" do
	  	it "fishbowl" do
	  		game = FactoryBot.create(:fishbowl)
	  		game_session = GameSession.create! attributes_for(:game_session, game_id: game.id)
	  		expect(game_session.scores.keys).to eq(game.scoring_rounds.keys)
	  	end
	  end
	end

	# describe "game_session with user" do
	# 	it "should take user name as player name" do
	# 		user = FactoryBot.create(:user)
	# 		game = FactoryBot.create(:fishbowl)
	# 		game_session = game.game_sessions.create(playerable: user, host: true, invitation_accepted: true)
	# 		expect(game_session.player_name).to eq(user.name)
	# 	end
	# end
end

require 'rails_helper'

RSpec.describe Team, type: :model do
  describe 'Associations' do
  	it { should have_many(:game_sessions) }
  	it { should have_many(:users) }
  	it { should belong_to(:game) }
  	it { should have_one(:chatroom) }
  end

  describe "setup_scores" do
  	context "will set up scores according to game type: " do
	  	it "fishbowl" do
	  		game = FactoryBot.create(:fishbowl)
	  		team = game.teams.create
	  		expect(team.scores.keys).to eq(game.scoring_rounds.keys)
	  	end
  	end
  end
end

require 'rails_helper'

RSpec.describe Game, type: :model do
	describe "Associations" do
  	it { should have_many(:game_sessions) }
  	it { should have_many(:teams) }
  	it { should have_many(:players) }
  	it { should have_many(:users) }
  end

  describe "Game initialises" do
  	context "fishbowl" do
			it "should set up game set json" do
				game = FactoryBot.create(:fishbowl)
				expect(game.set.keys).to include("clues", "current_clue", "guessed_clues", "current_round", "current_turn", "players_gone", "players_done_clues", "options")
			end
  	end
  	context "ghost" do
			it "should set up game set json" do
				game = FactoryBot.create(:ghost)
				expect(game.set.keys).to include("play_word", "word_definition", "challenge_results", "played_words", "current_round", "current_turn", "players_gone", "player_ghosts", "options", "rounds")
			end
  	end
  end

  describe "Game updates" do
  	describe "to start the game" do
	  	context "fishbowl" do
	  		context "with teams," do
	  			before(:each) do
	  				@game = FactoryBot.create(:fishbowl, team_mode: true)
	  				5.times {@game.teams.create}
	  				@game.update_attributes(started: true)
	  			end
	  			it "should setup current round to be the first round" do
	  				expect(@game.set["current_round"]["round_number"]).to eq(@game.rounds.keys.first)
	  			end
	  			it "should setup players gone according to teams" do
	  				expect(@game.set["players_gone"].keys.length).to eq(@game.teams.length)
	  			end 
	  		end

	  		context "without teams," do
	  			before(:all) do
	  				@game = FactoryBot.create(:fishbowl)
	  				@game.update_attributes(started: true)
	  			end
	  			it "should setup current round to be the first round" do
	  				expect(@game.set["current_round"]["round_number"]).to eq(@game.rounds.keys.first)
	  			end
	  			it "should setup players gone according to teams" do
	  				expect(@game.set["players_gone"]).to eq([])
	  			end 
	  		end
	  	end

	  	context "ghost" do
	  		before(:all) do
	  			@game = FactoryBot.create(:ghost)
	  			@game_sessions = FactoryBot.build_list(:game_session, 5, game_id: @game.id)
					@game_sessions.map(&:save)
	  			@game.update_attributes(started: true)
	  		end
	  		it "should setup current round to be the first round" do
	  			expect(@game.set["current_round"]["round_number"]).to eq(@game.rounds.keys.first.to_i)
	  		end
	  		it "should setup current turn nominated player" do
	  			expect(@game.set["current_turn"]["nominated_player"].present?).to be(true)
	  		end
	  	end
	  end
	end


	describe "populate fishbowl pot" do
		before(:all) do
			@game = FactoryBot.create(:fishbowl)
			@game_sessions = FactoryBot.build_list(:game_session, 5, game_id: @game.id)
			@game_sessions.map(&:save)
			@game.update_attributes(started: true)
			@game.update_attributes(set: {"clues" => ["this", "or"], "players_done_clues" => [@game_sessions[0].id]})
			@game.update_attributes(set: {"clues" => ["that", "which"], "players_done_clues" => [@game_sessions[1].id]})
			@game.update_attributes(set: {"clues" => [""], "players_done_clues" => [@game_sessions[2].id]})
			@game.update_attributes(set: {"clues" => ["this"], "players_done_clues" => [@game_sessions[3].id]})
			@game.update_attributes(set: {"clues" => ["other"], "players_done_clues" => [@game_sessions[4].id]})
		end

		it "should ADD clues to the pot with unique list" do
			expect(@game.set["clues"].uniq.length).to eq(5)
		end

		it "should ADD players who have submitted the clues" do
			expect(@game.set["players_done_clues"].length).to eq(@game_sessions.length)
		end
	end
  	
	context "with teams" do
		before(:each) do
  		@game = FactoryBot.create(:game, team_mode: true)
  		@game_sessions = FactoryBot.build_list(:game_session, 6, game_id: @game.id)
  		@game_sessions.map(&:save)
  		2.times { @game.teams.create }
  		team_division = @game_sessions.length / @game.teams.length
  		first_pick = @game_sessions.sample(team_division)
  		first_pick.map { |s| s.update_attributes(team_id: @game.teams.first.id)}
  		second_pick = @game_sessions - first_pick
  		second_pick.map { |s| s.update_attributes(team_id: @game.teams.second.id)}
  		@game.update_attributes(started: true)
  		@team_orders = @game.teams.sort_by(&:order).map(&:order)
  		
		end
		it "should change the turn to the next team" do
			@game.next_turn
			expect(@game.set["current_turn"]["team"]).not_to be @game.set_was["current_turn"]["team"]
			@game.next_turn
			expect(@game.set["current_turn"]["team"]).not_to be @game.set_was["current_turn"]["team"]
		end
		it "should change the turn to the next player not gone before" do
			@game.next_turn
			expect(@game.set["players_gone"][@game.set["current_turn"]["team"].to_s]).not_to include(@game.set["current_turn"]["nominated_player"])
			@game.next_turn
			expect(@game.set["players_gone"][@game.set["current_turn"]["team"].to_s]).not_to include(@game.set["current_turn"]["nominated_player"])
		end
		it "should cycle through teams" do
			@team_orders.cycle(10) do |team|
				@game.next_turn
				expect(@game.set["current_turn"]["team"]).to be(team)
				expect(@game.set["current_turn"]["team"]).not_to be(@game.set_was["current_turn"]["team"])
			end
		end

		it "should cycle through players each team" do
			# first_team_players = @game.teams.sort_by { |t| t.order }.first.game_sessions
			# second_team_players = @game.teams.sort_by { |t| t.order }.second.game_sessions
			gone_players = {}
			@game.teams.each do |team|
				gone_players[team.id] = []
			end
			@game.next_turn
			@game.teams.sort_by(&:order).cycle(12).with_index do |team, index|
				# puts "index #{index}"
				# puts "old team #{team.order}"
				# puts "old team #{@game.set["current_turn"]["team"]}"
				# puts "old player #{@game.set["current_turn"]["nominated_player"]}"
				
				if team.game_sessions.length == gone_players[team.id].length
					gone_players[team.id] = []
				end
				# puts gone_players
				# puts "compare to #{@game.set['players_gone']}"
				expect(gone_players[team.id]).not_to include(@game.set["current_turn"]["nominated_player"])
				expect(team.game_sessions.map(&:id)).to include(@game.set["current_turn"]["nominated_player"])
				gone_players[team.id].push(@game.set["current_turn"]["nominated_player"])
				@game.next_turn
				# puts "new team #{team.order}"
				# puts "new team #{@game.set["current_turn"]["team"]}"
				# puts "new player: #{@game.set["current_turn"]["nominated_player"]}"
			end
		end
	end

	context "without teams" do
		before(:each) do
			@game = FactoryBot.create(:game, team_mode: false)
  		@game_sessions = FactoryBot.build_list(:game_session, 5, game_id: @game.id)
  		@game_sessions.map(&:save)
  		@game.update_attributes(started: true)
  		
		end
		it "should change the turn to the next player not gone before" do
			@game.next_turn
			expect(@game.set["players_gone"]).not_to include(@game.set["current_turn"]["nominated_player"])
		end

		it "should cycle through the players" do
			player_ids = @game_sessions.sort_by(&:id)
			player_ids.cycle(12) do |game_session|
				@game.next_turn
				expect(@game.set["current_turn"]["nominated_player"]).to be(game_session.id)
			end
		end
	end
end

require 'rails_helper'

RSpec.describe Game, type: :model do
	describe "Associations" do
  	it { should have_many(:game_sessions) }
  	it { should have_many(:teams) }
  	it { should have_many(:players) }
  	it { should have_many(:users) }
  end

  describe "initialises" do
  	it "should set up game turn order" do
  		game = FactoryBot.create(:game)
  		expect(game.turn_order.keys).to include("current_turn", "players_gone")
  	end
  	context "fishbowl" do
			it "should set up game set json" do
				game = FactoryBot.create(:fishbowl)
				expect(game.turn_order.keys).to include("current_turn", "players_gone")
				expect(game.set.keys).to include("clues", "current_clue", "guessed_clues", "current_round", "players_done_clues", "options")
			end
  	end
  	context "ghost" do
			it "should set up game set json" do
				game = FactoryBot.create(:ghost)
				expect(game.turn_order.keys).to include("current_turn", "players_gone")
				expect(game.set.keys).to include("play_word", "word_definition", "challenge_results", "played_words", "current_round", "player_ghosts", "options", "rounds_played")
			end
  	end
  	context "wink murder" do
			it "should set up game set json" do
				game = FactoryBot.create(:wink_murder)
				expect(game.turn_order.keys).to include("current_turn")
				expect(game.set.keys).to include("current_round", "rounds_played", "options")
			end
  	end
  end

  describe "updates" do
  	describe "to start the game" do
	  	context "fishbowl" do
	  		context "with teams," do
	  			before(:each) do
	  				@game = FactoryBot.create(:fishbowl, team_mode: true)
	  				
	  				5.times {@game.teams.create}
	  				@game.update_attributes(started: true)
	  			end
	  			it "should setup current round to be the first round" do
	  				expect(@game.current_round["round_number"]).to eq(@game.rounds.keys.first)
	  			end
	  			it "should setup players gone according to teams" do
	  				expect(@game.players_gone.keys.length).to eq(@game.teams.length)
	  			end 
	  		end

	  		context "without teams," do
	  			before(:all) do
	  				@game = FactoryBot.create(:fishbowl)
	  				
	  				@game.update_attributes(started: true)
	  			end
	  			it "should setup current round to be the first round" do
	  				expect(@game.current_round["round_number"]).to eq(@game.rounds.keys.first)
	  			end
	  			it "should setup players gone according to teams" do
	  				expect(@game.players_gone).to eq([])
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
	  			expect(@game.current_round["round_number"]).to eq(@game.rounds.keys.first.to_i)
	  		end
	  		it "should setup current turn nominated player" do
	  			expect(@game.current_turn["nominated_player"].present?).to be(true)
	  		end
	  	end

	  	context "wink murder" do
	  		before(:all) do
	  			@game = FactoryBot.create(:wink_murder)
	  			@game_sessions = FactoryBot.build_list(:game_session, 10, game_id: @game.id)
					@game_sessions.map(&:save)
	  			@game.update_attributes(started: true)
	  		end
	  		it "should nominate a murder randomly from the players" do
	  			expect(@game_sessions.map(&:id)).to include(*@game.current_round["murderers"])
	  		end
	  		it "should setup killed list according to murder id" do
	  			expect(@game.current_round["killed"].keys).to eq(@game.current_round["murderers"].map(&:to_s))
	  		end
	  		it "should advance into round one" do
	  			expect(@game.current_round["round_number"]).to be(1)
	  		end
	  	end
	  end

	  describe "to play the game" do
	  	context "wink murder" do
	  		before(:each) do
	  			@game = FactoryBot.create(:wink_murder)
	  			@game.options = {number_of_murderers: 2, enable_chat: false}
	  			@game.save
	  			@game_sessions = FactoryBot.build_list(:game_session, 10, game_id: @game.id)
					@game_sessions.map(&:save)
	  			@game.update_attributes(started: true)
	  		end

	  		it "should save those killed" do
		  		civilians = @game_sessions.select { |s| !@game.current_round["murderers"].include?(s.id) }
		  		killed = civilians.first
		  		@game.current_turn["killed"] = killed.id
		  		killer =  @game.current_round["murderers"].first
		  		@game.current_turn["murderer"] = killer
		  		@game.save
		  		expect(@game.current_round["killed"][killer.to_s]).to include(killed.id)
	  		end

	  		it "should end the round if all killed" do
	  			civilians = @game_sessions.select { |s| !@game.current_round["murderers"].include?(s.id) }
		  		civilians.each do |civilian|
			  		@game.current_turn["killed"] = civilian.id
			  		killer =  @game.current_round["murderers"].first
			  		@game.current_turn["murderer"] = killer
			  		@game.save
			  		expect(@game.current_round["killed"][killer.to_s]).to include(civilian.id)
			  	end
			  	expect(@game.current_round["completed"]).to be(true)
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
			expect(@game.current_turn["team"]).not_to be @game.turn_order_was["current_turn"]["team"]
			@game.next_turn
			expect(@game.current_turn["team"]).not_to be @game.turn_order_was["current_turn"]["team"]
		end
		it "should change the turn to the next player not gone before" do
			@game.next_turn
			expect(@game.players_gone[@game.current_turn["team"].to_s]).not_to include(@game.current_turn["nominated_player"])
			@game.next_turn
			expect(@game.players_gone[@game.current_turn["team"].to_s]).not_to include(@game.current_turn["nominated_player"])
		end
		it "should cycle through teams" do
			@team_orders.cycle(10) do |team|
				@game.next_turn
				expect(@game.current_turn["team"]).to be(team)
				expect(@game.current_turn["team"]).not_to be(@game.turn_order_was["current_turn"]["team"])
			end
		end

		it "should cycle through players each team" do
			gone_players = {}
			@game.teams.each do |team|
				gone_players[team.id] = []
			end
			@game.next_turn
			@game.teams.sort_by(&:order).cycle(12).with_index do |team, index|
				
				if team.game_sessions.length == gone_players[team.id].length
					gone_players[team.id] = []
				end

				expect(gone_players[team.id]).not_to include(@game.current_turn["nominated_player"])
				expect(team.game_sessions.map(&:id)).to include(@game.current_turn["nominated_player"])
				gone_players[team.id].push(@game.current_turn["nominated_player"])
				@game.next_turn

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
			expect(@game.players_gone).not_to include(@game.current_turn["nominated_player"])
		end

		it "should cycle through the players" do
			player_ids = @game_sessions.sort_by(&:id)
			player_ids.cycle(12) do |game_session|
				@game.next_turn
				expect(@game.current_turn["nominated_player"]).to be(game_session.id)
			end
		end
	end
end

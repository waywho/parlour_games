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
				expect(game.set.keys).to include("clues", "current_clue", "guessed_clues", "current_round", "players_done_clues")
				expect(game.options).to include("time_limit", "enable_team_mode", "enable_chat")
			end
  	end
  	context "ghost" do
			it "should set up game set json" do
				game = FactoryBot.create(:ghost)
				expect(game.turn_order.keys).to include("current_turn", "players_gone")
				expect(game.set.keys).to include("play_word", "word_definition", "challenge_results", "played_words", "current_round", "player_ghosts", "rounds_played")
				expect(game.options).to include("language", "team_mode", "min_word_length")
			end
  	end
  	context "wink murder" do
			it "should set up game set json" do
				game = FactoryBot.create(:wink_murder)
				expect(game.turn_order.keys).to include("current_turn")
				expect(game.set.keys).to include("current_round", "rounds_played")
				expect(game.options).to include("number_of_murderers", "enable_chat")
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
	  				expect(@game.current_round[:round_number]).to eq(@game.rounds.keys.first)
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
	  				expect(@game.current_round[:round_number]).to eq(@game.rounds.keys.first)
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
	  			expect(@game.current_round[:round_number]).to eq(@game.rounds.keys.first.to_i)
	  		end
	  		it "should setup current turn nominated player" do
	  			expect(@game.current_turn[:nominated_player].present?).to be(true)
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
	  			expect(@game_sessions.map(&:id)).to include(*@game.current_round[:murderers])
	  		end
	  		it "should set up out list according to murder id" do
	  			expect(@game.current_round[:out_list].keys).to include(*@game.current_round[:murderers].map(&:to_s))
	  		end
	  		it "should advance into round one" do
	  			expect(@game.current_round[:round_number]).to be(1)
	  		end
	  		it "should set up lookers list according to players id" do
	  			expect(@game.lookers.keys).to eq(@game.game_sessions.map(&:id).map(&:to_s))
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
	  			@civilians = @game_sessions.select { |s| !@game.current_round[:murderers].include?(s.id) }
	  			@killer_id =  @game.current_round[:murderers].first
	  			@second_killer_id =  @game.current_round[:murderers].last
	  			@outed = @civilians[rand(@civilians.length - 1)]
	  			@potential_points = (@civilians.length / @game.current_round[:murderers].length).round
	  		end

	  		def commit_murder(game, killer_id, outed_id)
	  			game.looking_turn[:looker] = killer_id
	  			game.looking_turn[:looking] = outed_id
	  			game.save
	  			game.looking_turn[:looker] = outed_id
	  			game.looking_turn[:looking] = killer_id
	  			game.save
		  		game.current_turn[:outed] = outed_id
		  		game.current_turn[:murderer] = killer_id
		  		game.save
	  		end

	  		it "should save who is and is not looking at each player" do
	  			randIndex = rand(@game_sessions.length - 1)
	  			looking = @game_sessions[randIndex]
	  			looker = @game_sessions[randIndex + 1] || @game_sessions[randIndex - 1]
	  			@game.looking_turn[:looker] = looker.id
	  			@game.looking_turn[:looking] = looking.id
	  			@game.save
	  			expect(@game.lookers[looking.id.to_s]).to include(looker.id)
	  			@game_sessions.each do |session|
	  				if session.id != looking.id
	  					expect(@game.lookers[session.id.to_s]).not_to include(looker.id)
	  				end
	  			end
	  		end

	  		it "should save those outed if murderer and civilian are looking at each other" do
	  			commit_murder(@game, @killer_id, @outed.id)
		  		@game.reload
		  		expect(@game.current_round[:out_list][@killer_id.to_s]).to include(@outed.id)
	  		end

	  		it "should NOT save those outed if murderer and civilian are NOT looking at each other" do
	  			@game.current_turn[:outed] = @outed.id
		  		@game.current_turn[:murderer] = @killer_id
		  		@game.save
		  		@game.reload
		  		expect(@game.current_round[:out_list][@killer_id.to_s]).not_to include(@outed.id)
	  		end

	  		it "should NOT save those outed if only murderer  is NOT looking at the civilian" do
	  			@game.looking_turn[:looker] = @killer_id
	  			@game.looking_turn[:looking] = @outed.id
	  			@game.save
	  			@game.current_turn[:outed] = @outed.id
		  		@game.current_turn[:murderer] = @killer_id
		  		@game.save
		  		@game.reload
		  		expect(@game.current_round[:out_list][@killer_id.to_s]).not_to include(@outed.id)
	  		end

	  		it "should end the round if all outed" do
	  			killer_id =  @game.current_round[:murderers].first
		  		@civilians.each do |civilian|

		  			commit_murder(@game, killer_id, civilian.id)

			  		expect(@game.current_round[:out_list][killer_id.to_s]).to include(civilian.id)
			  	end
			  	expect(@game.current_round[:completed]).to be(true)
	  		end

	  		it "should grant murderer a point for the round when one is murdered" do
	  			murderer = @game_sessions.select { |s| s.id == @killer_id }.first
	  			old_score = murderer.scores[@game.current_round[:round_number].to_s]
	  			
	  			commit_murder(@game, @killer_id, @outed.id)
	  			
		  		murderer.reload
		  		new_score = murderer.scores[@game.current_round[:round_number].to_s]
		  		expect(new_score).to eq(old_score += 1)
	  		end

	  		# accusing murderers

	  		def seconder(game, civilians)
	  			game.accusations[:first][:accuser] = civilians[1].id
	  			game.current_round["phase"] = "seconder-seeking"
	  			game.save
	  			game.accusations[:second][:accuser] = civilians[2].id
	  			game.current_round["phase"] = "accusation"
	  		end

	  		it "should not allow second accuser if game is not in seconder-seaking phase" do
	  			@game.accusations[:first][:accuser] = @civilians[1].id
	  			@game.save
	  			@game.reload
	  			expect(@game.accusations[:second]).to be(nil)
	  		end

	  		it "should not allow any accused if game is not in accusation phase" do
	  			@game.accusations[:first][:accuser] = @civilians[1].id
	  			@game.current_round["phase"] = "seconder-seeking"
	  			@game.save
	  			@game.reload
	  			expect(@game.accusations.keys).to include("second")
	  			expect(@game.accusations[:second].keys).to include("accuser")
	  			expect(@game.accusations[:second].keys).not_to include("accused")
	  			expect(@game.accusations[:first].keys).not_to include("accused")
	  		end

	  		it "should allow naming accused if game is in accusation phase" do
	  			seconder(@game, @civilians)
	  			@game.save
	  			@game.reload
	  			expect(@game.accusations[:first].keys).to include("accused")
	  			expect(@game.accusations[:second].keys).to include("accused")
	  		end

	  		it "should accept named accused if game is in challenge phase" do
	  			@game.accusations[:first][:accused] = @civilians[3].id
	  			@game.current_round["phase"] = "challenge"
	  			@game.save
	  			@game.reload
	  			expect(@game.accusations[:first][:accused]).to eq(@civilians[3].id)
	  		end

	  		it "should add the murderer to out_list and remove from murderer list if one of the accuser is correct (first)" do
	  			seconder(@game, @civilians)
	  			@game.accusations[:first][:accused] = @killer_id
	  			@game.accusations[:second][:accused] = @civilians[3].id
	  			@game.current_round["phase"] = "challenge"
	  			@game.save
	  			@game.reload
	  			expect(@game.current_round[:murderers]).not_to include(@killer_id)
	  			out_players = @game.current_round[:out_list].values.flatten
	  			expect(out_players).to include(@killer_id)
	  			expect(out_players).not_to include(@game.accusations[:second][:accused])
	  			expect(out_players).to include(@game.accusations[:second][:accuser])
	  		end

	  		it "should add the murderer to out_list and remove from murderer list if one of the accuser is correct (second)" do
	  			seconder(@game, @civilians)
	  			@game.accusations[:first][:accused] = @civilians[3].id 
	  			@game.accusations[:second][:accused] = @killer_id
	  			@game.current_round["phase"] = "challenge"
	  			@game.save
	  			@game.reload
	  			expect(@game.current_round[:murderers]).not_to include(@killer_id)
	  			out_players = @game.current_round[:out_list].values.flatten
	  			expect(out_players).to include(@killer_id)
	  			expect(out_players).not_to include(@game.accusations[:first][:accused])
	  			expect(out_players).to include(@game.accusations[:first][:accuser])
	  		end

	  		it "should NOT add the murderer to out_list and NOT remove from murderer list if both of the accused are incorrect" do
	  			seconder(@game, @civilians)
	  			@game.accusations[:first][:accused] = @civilians[3].id
	  			@game.accusations[:second][:accused] = @civilians[4].id
	  			@game.current_round["phase"] = "challenge"
	  			@game.save
	  			@game.reload
	  			expect(@game.current_round[:murderers]).to include(@killer_id)
	  			out_players = @game.current_round[:out_list].values.flatten
	  			expect(out_players).not_to include(@killer_id)
	  			expect(out_players).not_to include(@civilians[3].id)
	  			expect(out_players).not_to include(@civilians[4].id)
	  			expect(out_players).to include(@game.accusations[:first][:accuser])
	  			expect(out_players).to include(@game.accusations[:second][:accuser])
	  		end
	  		
	  		it "should grant first accuser the potential points if only first accuser is correct" do
	  			seconder(@game, @civilians)
	  			@game.accusations[:first][:accused] = @killer_id
	  			@game.accusations[:second][:accused] = @civilians[3].id
	  			@game.current_round["phase"] = "challenge"

	  			first_accuser = @game_sessions.select { |s| s.id == @game.accusations[:first][:accuser] }.first
	  			first_accuser_old_score = first_accuser.scores[@game.current_round[:round_number].to_s]
	  			second_accuser = @game_sessions.select { |s| s.id == @game.accusations[:second][:accuser] }.first
	  			second_accuser_old_score = second_accuser.scores[@game.current_round[:round_number].to_s]
	  			@game.save
	  			@game.reload
	  			first_accuser.reload
	  			second_accuser.reload
	  			first_accuser_new_score = first_accuser.scores[@game.current_round[:round_number].to_s]
	  			second_accuser_new_score = second_accuser.scores[@game.current_round[:round_number].to_s]

	  	
	  			expect(first_accuser_new_score).to eq(first_accuser_old_score + @potential_points)
	  			expect(second_accuser_new_score).not_to eq(second_accuser_old_score + @potential_points)
	  		end

	  		it "should grant second accuser all the potential points if first accuser is correct" do
	  			seconder(@game, @civilians)
	  			@game.accusations[:first][:accused] = @civilians[3].id
	  			@game.accusations[:second][:accused] = @killer_id
	  			@game.current_round["phase"] = "challenge"

	  			first_accuser = @game_sessions.select { |s| s.id == @game.accusations[:first][:accuser] }.first
	  			first_accuser_old_score = first_accuser.scores[@game.current_round[:round_number].to_s]
	  			second_accuser = @game_sessions.select { |s| s.id == @game.accusations[:second][:accuser] }.first
	  			second_accuser_old_score = second_accuser.scores[@game.current_round[:round_number].to_s]

	  			@game.save
	  			@game.reload
					
					first_accuser.reload
	  			second_accuser.reload
	  			first_accuser_new_score = first_accuser.scores[@game.current_round[:round_number].to_s]
	  			second_accuser_new_score = second_accuser.scores[@game.current_round[:round_number].to_s]

	  			expect(first_accuser_new_score).not_to eq(first_accuser_old_score + @potential_points)
	  			expect(second_accuser_new_score).to eq(second_accuser_old_score + @potential_points)
	  		end

	  		it "should grant the all correct accusers with the same accused all the potential points" do
	  			seconder(@game, @civilians)
	  			@game.accusations[:first][:accused] = @killer_id
	  			@game.accusations[:second][:accused] = @killer_id
	  			@game.current_round["phase"] = "challenge"


	  			first_accuser = @game_sessions.select { |s| s.id == @game.accusations[:first][:accuser] }.first
	  			first_accuser_old_score = first_accuser.scores[@game.current_round[:round_number].to_s]
	  			second_accuser = @game_sessions.select { |s| s.id == @game.accusations[:second][:accuser] }.first
	  			second_accuser_old_score = second_accuser.scores[@game.current_round[:round_number].to_s]

	  			@game.save
	  			@game.reload
					
					first_accuser.reload
	  			second_accuser.reload
	  			first_accuser_new_score = first_accuser.scores[@game.current_round[:round_number].to_s]
	  			second_accuser_new_score = second_accuser.scores[@game.current_round[:round_number].to_s]

	  			expect(first_accuser_new_score).to eq(first_accuser_old_score + @potential_points)
	  			expect(second_accuser_new_score).to eq(second_accuser_old_score + @potential_points)
	  		end

	  		it "should grant the all correct accusers with different accused all the potential points" do
	  			seconder(@game, @civilians)
	  			@game.accusations[:first][:accused] = @second_killer_id
	  			@game.accusations[:second][:accused] = @killer_id
	  			@game.current_round["phase"] = "challenge"


	  			first_accuser = @game_sessions.select { |s| s.id == @game.accusations[:first][:accuser] }.first
	  			first_accuser_old_score = first_accuser.scores[@game.current_round[:round_number].to_s]
	  			second_accuser = @game_sessions.select { |s| s.id == @game.accusations[:second][:accuser] }.first
	  			second_accuser_old_score = second_accuser.scores[@game.current_round[:round_number].to_s]

	  			@game.save
	  			@game.reload
					
					first_accuser.reload
	  			second_accuser.reload
	  			first_accuser_new_score = first_accuser.scores[@game.current_round[:round_number].to_s]
	  			second_accuser_new_score = second_accuser.scores[@game.current_round[:round_number].to_s]

	  			expect(first_accuser_new_score).to eq(first_accuser_old_score + @potential_points)
	  			expect(second_accuser_new_score).to eq(second_accuser_old_score + @potential_points)
	  		end
	  		
	  		it "should end the round if all killers are found" do
	  			@game.current_round[:murderers].each do |killer_id|
	  				seconder(@game, @civilians)
	  				@game.accusations[:first][:accused] = killer_id
	  				@game.accusations[:second][:accused] = @civilians[3].id
	  				@game.current_round["phase"] = "challenge"
	  				@game.save
	  			end
	  			@game.reload
	  			expect(@game.current_round[:completed]).to eq(true)
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
			expect(@game.players_done_clues.length).to eq(@game_sessions.length)
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
			expect(@game.current_turn[:team]).not_to be @game.turn_order_was[:current_turn][:team]
			@game.next_turn
			expect(@game.current_turn[:team]).not_to be @game.turn_order_was[:current_turn][:team]
		end
		it "should change the turn to the next player not gone before" do
			@game.next_turn
			expect(@game.players_gone[@game.current_turn[:team].to_s]).not_to include(@game.current_turn[:nominated_player])
			@game.next_turn
			expect(@game.players_gone[@game.current_turn[:team].to_s]).not_to include(@game.current_turn[:nominated_player])
		end
		it "should cycle through teams" do
			@team_orders.cycle(10) do |team|
				@game.next_turn
				expect(@game.current_turn[:team]).to be(team)
				expect(@game.current_turn[:team]).not_to be(@game.turn_order_was[:current_turn][:team])
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

				expect(gone_players[team.id]).not_to include(@game.current_turn[:nominated_player])
				expect(team.game_sessions.map(&:id)).to include(@game.current_turn[:nominated_player])
				gone_players[team.id].push(@game.current_turn[:nominated_player])
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
			expect(@game.players_gone).not_to include(@game.current_turn[:nominated_player])
		end

		it "should cycle through the players" do
			player_ids = @game_sessions.sort_by(&:id)
			player_ids.cycle(12) do |game_session|
				@game.next_turn
				expect(@game.current_turn[:nominated_player]).to be(game_session.id)
			end
		end
	end
end

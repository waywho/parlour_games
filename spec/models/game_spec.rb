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
				expect(game.turn_order.keys).to include("current_turn", "players_gone", "challenge")
				expect(game.set.keys).to include("play_word", "played_words", "current_round", "player_ghosts", "rounds_played")
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
  	describe "to start" do
	  	context "fishbowl" do
	  		context "with teams," do
	  			let(:game) {
	  				FactoryBot.create(:fishbowl, team_mode: true)
	  			}
	  			before do
	  				5.times {game.teams.create}
	  				game.update_attributes(started: true)
	  			end
	  			it "should setup current round to be the first round" do
	  				expect(game.current_round[:round_number]).to eq(game.rounds.keys.first)
	  			end
	  			it "should setup players gone according to teams" do
	  				expect(game.players_gone.keys.length).to eq(game.teams.length)
	  			end 
	  		end

	  		context "without teams," do
	  			let(:game) {
	  				FactoryBot.create(:fishbowl)
	  			}
	  			before do
	  				game.update_attributes(started: true)
	  			end
	  			it "should setup current round to be the first round" do
	  				expect(game.current_round[:round_number]).to eq(game.rounds.keys.first)
	  			end
	  			it "should setup players gone according to teams" do
	  				expect(game.players_gone).to eq([])
	  			end 
	  		end
	  	end

	  	context "ghost" do
	  		let(:game) {
	  			FactoryBot.create(:ghost)
	  		}

	  		let(:game_sessions) {
	  			FactoryBot.build_list(:game_session, 5, game_id: game.id)
	  		}
	  		before do
					game_sessions.map(&:save)
	  			game.update_attributes(started: true)
	  		end
	  		it "should setup current round to be the first round" do
	  			expect(game.current_round[:round_number]).to eq(game.rounds.keys.first.to_i)
	  		end
	  		it "should setup current turn nominated player" do
	  			expect(game.current_turn[:nominated_player].present?).to be(true)
	  		end
	  	end

	  	context "wink murder" do
	  		let(:game) {
	  			FactoryBot.create(:wink_murder)
	  		}

	  		let(:game_sessions) {
	  			FactoryBot.build_list(:game_session, 5, game_id: game.id)
	  		}

	  		before do
					game_sessions.map(&:save)
	  			game.update_attributes(started: true)
	  		end
	  		it "should nominate a murder randomly from the players" do
	  			expect(game_sessions.map(&:id)).to include(*game.current_round[:murderers])
	  		end
	  		it "should set up out list according to murder id" do
	  			expect(game.current_round[:out_list].keys).to include(*game.current_round[:murderers].map(&:to_s))
	  		end
	  		it "should advance into round one" do
	  			expect(game.current_round[:round_number]).to be(1)
	  		end
	  		it "should set up lookers list according to players id" do
	  			expect(game.lookers.keys).to eq(game.game_sessions.map(&:id).map(&:to_s))
	  		end
	  	end
	  end

	  describe "to play" do
	  	context "ghost" do
	  		let(:game) {
	  			FactoryBot.create(:ghost)
	  		}

	  		let(:game_sessions) {
	  			FactoryBot.build_list(:game_session, 5, game_id: game.id)
	  		
	  		}
	  		before(:each) do
					game_sessions.map(&:save)
	  			game.update_attributes(started: true)
	  		end

	  		let(:player_ids) {
	  			game_sessions.map(&:id)
	  		}

	  		def play_complete_word
	  			game.play_word << "a"
	  			game.save
	  			game.play_word << "b"
	  			game.save
	  			game.play_word << "s"
	  			
	  		end

	  		it "should let players to play each letter" do
	  			play_complete_word
	  			expect(game.play_word).to include("a", "b", "s")
	  		end

	  		it "should make last player loose challenge if a word is completed" do
	  			play_complete_word
	  			last_player_id = game.current_turn[:nominated_player]
	  			game.save
	  			player_ids.delete(last_player_id)
	  			challenge_player = player_ids.first
	  			last_ghost = game.player_ghosts[last_player_id.to_s].length
	  			game.challenge[:type] = "word_complete"
	  			game.challenge[:challenger] = challenge_player
	  			game.save
	  			expect(game.player_ghosts[last_player_id.to_s].length).to eq(last_ghost + 1)
	  			expect(game.play_word.empty?).to eq(true)
	  		end

	  		it "should make challenger loose challenge if a word is NOT completed" do
	  			game.play_word << "a"
	  			game.save
	  			game.play_word << "w"
	  			game.save
	  			game.play_word << "r"
	  			

	  			last_player_id = game.current_turn[:nominated_player]
	  			game.save
	  			player_ids.delete(last_player_id)

	  			challenger = player_ids.first

	  			last_ghost = game.player_ghosts[challenger.to_s].length
	  			game.challenge[:type] = "word_complete"
	  			game.challenge[:challenger] = challenger

	  			game.save
	  			expect(game.player_ghosts[challenger.to_s].length).to eq(last_ghost + 1)
	  			expect(game.play_word.empty?).to eq(true)
	  		end

	  		it "should make challenger loose challenge if a word has potential" do
	  			game.play_word << "a"
	  			game.save
	  			game.play_word << "w"
	  			game.save
	  			game.play_word << "r"

	  			last_player_id = game.current_turn[:nominated_player]
	  			game.save
	  			player_ids.delete(last_player_id)

	  			challenger = player_ids.first

	  			last_ghost = game.player_ghosts[challenger.to_s].length
	  			game.challenge[:type] = "spelling"
	  			game.challenge[:challenger] = challenger

	  			game.save
	  			expect(game.player_ghosts[challenger.to_s].length).to eq(last_ghost + 1)
	  			expect(game.play_word.empty?).to eq(true)
	  		end

	  		it "should make last player loose challenge if a word has no potential" do
	  			game.play_word << "a"
	  			game.save
	  			game.play_word << "v"
	  			game.save
	  			game.play_word << "q"

	  			last_player_id = game.current_turn[:nominated_player]

	  			game.save
	  			player_ids.delete(last_player_id)

	  			challenger = player_ids.first

	  			last_ghost = game.player_ghosts[last_player_id.to_s].length
	  			game.challenge[:type] = "spelling"
	  			game.challenge[:challenger] = challenger

	  			game.save
	  			expect(game.player_ghosts[last_player_id.to_s].length).to eq(last_ghost + 1)
	  			expect(game.play_word.empty?).to eq(true)
	  		end
	  	end
	  	context "wink murder" do
	  		let(:game) {
	  			FactoryBot.create(:wink_murder)
	  		}

	  		let(:game_sessions) {
	  			FactoryBot.build_list(:game_session, 10, game_id: game.id)
	  		}
	  		before(:each) do
	  			game.options = {number_of_murderers: 2, enable_chat: false}
	  			game.save
					game_sessions.map(&:save)
	  			game.update_attributes(started: true)
	  		end

	  		let(:civilians) {
	  			game_sessions.select { |s| !game.current_round[:murderers].include?(s.id) }
	  		}

	  		let(:killer_id) {
	  			game.current_round[:murderers][rand(game.current_round[:murderers].length - 1)]
	  		}

	  		let(:second_killer_id) {
	  			murderers = game.current_round[:murderers].dup
	  			murderers.delete(killer_id)
	  			murderers[rand(murderers.length - 1)]
	  		}

	  		let(:outed) {
	  			civilians[rand(civilians.length - 1)]
	  		}

	  		def commit_murder(id_killer, outed_id)
	  			game.looking_turn[:looker] = id_killer
	  			game.looking_turn[:lookee] = outed_id
	  			game.save
	  			game.looking_turn[:looker] = outed_id
	  			game.looking_turn[:lookee] = id_killer
	  			game.save
		  		game.current_turn[:outed] = outed_id
		  		game.current_turn[:murderer] = id_killer
		  		game.save
		  		game.reload
		  		game
	  		end

	  		it "should save who is and is not looking at each player" do
	  			randIndex = rand(game_sessions.length - 1)
	  			lookee = game_sessions[randIndex]
	  			looker = game_sessions[randIndex + 1] || game_sessions[randIndex - 1]
	  			game.looking_turn[:looker] = looker.id
	  			game.looking_turn[:lookee] = lookee.id
	  			game.save
	  			expect(game.lookers[lookee.id.to_s]).to include(looker.id)
	  			game_sessions.each do |session|
	  				if session.id != lookee.id
	  					expect(game.lookers[session.id.to_s]).not_to include(looker.id)
	  				end
	  			end
	  		end

	  		it "should save those outed if murderer and civilian are looking at each other" do
	  			outed_id = outed.id
	  			new_killer_id = killer_id
		  		expect(commit_murder(new_killer_id, outed_id).current_round[:out_list][new_killer_id.to_s]).to include(outed_id)
	  		end

	  		it "should NOT save those outed if murderer and civilian are NOT looking at each other" do
	  			outed_id = outed.id
	  			new_killer_id = killer_id
	  			game.current_turn[:outed] = outed_id
		  		game.current_turn[:murderer] = new_killer_id
		  		game.save
		  		game.reload
		  		expect(game.current_round[:out_list][new_killer_id.to_s]).not_to include(outed_id)
	  		end

	  		it "should NOT save those outed if murderer is NOT looking at the civilian" do
	  			outed_id = outed.id
	  			new_killer_id = killer_id
	  			game.looking_turn[:looker] = outed_id
	  			game.looking_turn[:lookee] = civilians[1].id
	  			game.save
	  			game.reload
	  			game.looking_turn[:looker] = new_killer_id
	  			game.looking_turn[:lookee] = outed_id
	  			game.save
	  			game.reload
	  			game.current_turn[:outed] = outed_id
		  		game.current_turn[:murderer] = new_killer_id
		  		game.save
		  		game.reload
		  		expect(game.current_round[:out_list][new_killer_id.to_s]).not_to include(outed_id)
	  		end

	  		it "should end the round if all outed" do
	  			new_killer_id = killer_id
		  		civilians.each do |civilian|
		  			updated_game = commit_murder(new_killer_id, civilian.id)
			  		expect(updated_game.current_round[:out_list][new_killer_id.to_s]).to include(civilian.id)
			  	end
			  	game.reload
			  	expect(game.current_round[:completed]).to be(true)
	  		end

	  		it "should grant murderer a point for the round when one is murdered" do
	  			new_killer_id = killer_id
	  			outed_id = outed.id
	  			murderer = game_sessions.select { |s| s.id == new_killer_id }.first
	  			old_score = murderer.scores[game.current_round[:round_number].to_s]
	  			
	  			commit_murder(new_killer_id, outed_id)
	  			
		  		murderer.reload
		  		new_score = murderer.scores[game.current_round[:round_number].to_s]
		  		expect(new_score).to eq(old_score += 1)
	  		end

	  		# accusing murderers

	  		def seconder
	  			game.accusations[:first][:accuser] = civilians[1].id
	  			game.save
	  			game.accusations[:second][:accuser] = civilians[2].id
	  			game.save
	  			return civilians[1].id, civilians[2].id
	  		end

	  		def get_old_scores
	  			first_accuser = game_sessions.select { |s| s.id == game.accusations[:first][:accuser] }.first
	  			first_accuser_old_score = first_accuser.scores[game.current_round[:round_number].to_s]
	  			second_accuser = game_sessions.select { |s| s.id == game.accusations[:second][:accuser] }.first
	  			second_accuser_old_score = second_accuser.scores[game.current_round[:round_number].to_s]
	  			
	  			return first_accuser, second_accuser, first_accuser_old_score, second_accuser_old_score
	  		end

	  		def get_new_scores(first_accuser, second_accuser)
	  			first_accuser.reload
	  			second_accuser.reload
	  			first_accuser_new_score = first_accuser.scores[game.current_round[:round_number].to_s]
	  			second_accuser_new_score = second_accuser.scores[game.current_round[:round_number].to_s]
	  			return first_accuser_new_score, second_accuser_new_score
	  		end

	  		# acusation phases

	  		it "should move into seconder-seeking phase if first accuser volunteered" do
	  			game.accusations[:first][:accuser] = civilians[1].id
	  			game.save
	  			expect(game.current_round[:phase]).to eq("seconder-seeking")
	  		end
	  		
	  		it "should move into accusation phase if both accusers volunteered" do
	  			seconder
	  			expect(game.current_round[:phase]).to eq("accusation")
	  		end

	  		it "should move into challenge phase if both accused are present" do
	  			seconder
	  			game.accusations[:first][:accused] = civilians[3].id
	  			game.accusations[:second][:accused] = civilians[4].id
					game.check_accusation_phases
	  			expect(game.current_round[:phase]).to eq("challenge")
	  			expect(game.accusations[:first][:accused]).to eq(civilians[3].id)
	  			expect(game.accusations[:second][:accused]).to eq(civilians[4].id)
	  		end

	  		# accusations

	  		it "should not allow second accuser if first accuser is not present" do
	  			expect(game.accusations[:second]).to be(nil)
	  		end

	  		it "should not allow any to be accused if there is no second accuser" do
	  			game.accusations[:first][:accuser] = civilians[1].id

	  			game.save
	  			game.reload
	  			expect(game.accusations.keys).to include("second")
	  			expect(game.accusations[:second].keys).to include("accuser")
	  			expect(game.accusations[:second].keys).not_to include("accused")
	  			expect(game.accusations[:first].keys).not_to include("accused")
	  		end

	  		it "should allow naming accused if both accusers present" do
	  			seconder
	  			game.reload
	  			expect(game.accusations[:first].keys).to include("accused")
	  			expect(game.accusations[:second].keys).to include("accused")
	  		end

	  		it "should add one murderer to out_list if both accusers are correct" do
	  			first_accuser, second_accuser = seconder
	  			game.accusations[:first][:accused] = killer_id
	  			game.accusations[:second][:accused] = killer_id
	  			game.save
	  			game.reload
	  			out_players = game.current_round[:out_list].values.flatten
	  			expect(out_players).to include(killer_id)
	  			expect(out_players).to include(killer_id)
	  			expect(out_players).not_to include(first_accuser)
	  			expect(out_players).not_to include(second_accuser)
	  		end

	  		it "should add one murderer to out_list if both accusers are correct" do
	  			first_accuser, second_accuser = seconder
	  			game.accusations[:first][:accused] = killer_id
	  			game.accusations[:second][:accused] = second_killer_id
	  			game.save
	  			game.reload
	  			out_players = game.current_round[:out_list].values.flatten
	  			expect(out_players).to include(killer_id)
	  			expect(out_players).to include(second_killer_id)
	  			expect(out_players).not_to include(first_accuser)
	  			expect(out_players).not_to include(second_accuser)
	  		end

	  		it "should add the murderer to out_list if one of the accuser is correct (first)" do
	  			first_accuser, second_accuser = seconder
	  			game.accusations[:first][:accused] = killer_id
	  			game.accusations[:second][:accused] = civilians[3].id
	  			game.save
	  			game.reload
	  			out_players = game.current_round[:out_list].values.flatten
	  			expect(out_players).to include(killer_id)
	  			expect(out_players).to include(second_accuser)
	  			expect(out_players).not_to include(civilians[3].id)
	  			expect(out_players).not_to include(first_accuser)
	  		end

	  		it "should add the murderer to out_list if one of the accuser is correct (second)" do
	  			first_accuser, second_accuser = seconder
	  			game.accusations[:first][:accused] = civilians[3].id 
	  			game.accusations[:second][:accused] = killer_id
	  			game.save
	  			game.reload
	  			out_players = game.current_round[:out_list].values.flatten
	  			expect(out_players).to include(first_accuser)
	  			expect(out_players).to include(killer_id)
	  			expect(out_players).not_to include(second_accuser)
	  			expect(out_players).not_to include(civilians[3].id )
	  		end

	  		it "should NOT add the murderer to out_list and NOT remove from murderer list if both of the accused are incorrect" do
	  			first_accuser, second_accuser = seconder
	  			game.accusations[:first][:accused] = civilians[3].id
	  			game.accusations[:second][:accused] = civilians[4].id
	  			game.save
	  			game.reload
	  			out_players = game.current_round[:out_list].values.flatten
	  			expect(out_players).not_to include(killer_id)
	  			expect(out_players).not_to include(civilians[3].id)
	  			expect(out_players).not_to include(civilians[4].id)
	  			expect(out_players).to include(first_accuser)
	  			expect(out_players).to include(second_accuser)
	  		end

	  		# scoring calculations for players to catch murerer

	  		it "should grant first accuser the potential points if only first accuser is correct" do
	  			seconder
	  			game.accusations[:first][:accused] = killer_id
	  			game.accusations[:second][:accused] = civilians[3].id

	  			first_accuser, second_accuser, first_accuser_old_score, second_accuser_old_score = get_old_scores
	  			potential_points = (civilians.length / game.current_round[:murderers].length).round
	  			game.save
	  			game.reload
	  			
	  			first_accuser_new_score, second_accuser_new_score = get_new_scores(first_accuser, second_accuser)
	  			expect(first_accuser_new_score).to eq(first_accuser_old_score + potential_points)
	  			expect(second_accuser_new_score).not_to eq(second_accuser_old_score + potential_points)
	  		end	  		

	  		it "should grant second accuser all the potential points if first accuser is correct" do
	  			seconder
	  			game.accusations[:first][:accused] = civilians[3].id
	  			game.accusations[:second][:accused] = killer_id

	  			first_accuser, second_accuser, first_accuser_old_score, second_accuser_old_score = get_old_scores

	  			potential_points = (civilians.length / game.current_round[:murderers].length).round

	  			game.save
	  			game.reload
				
					first_accuser_new_score, second_accuser_new_score = get_new_scores(first_accuser, second_accuser)

	  			expect(first_accuser_new_score).not_to eq(first_accuser_old_score + potential_points)
	  			expect(second_accuser_new_score).to eq(second_accuser_old_score + potential_points)
	  		end

	  		it "should grant all correct accusers with the same accused all the potential points" do
	  			seconder
	  			game.accusations[:first][:accused] = killer_id
	  			game.accusations[:second][:accused] = killer_id

	  			first_accuser, second_accuser, first_accuser_old_score, second_accuser_old_score = get_old_scores
	  			potential_points = (civilians.length / game.current_round[:murderers].length).round

	  			game.save
	  			game.reload

					first_accuser_new_score, second_accuser_new_score = get_new_scores(first_accuser, second_accuser)
	  			
	  			expect(first_accuser_new_score).to eq(first_accuser_old_score + potential_points)
	  			expect(second_accuser_new_score).to eq(second_accuser_old_score + potential_points)
	  		end

	  		it "should grant the all correct accusers with different accused all the potential points" do
	  			seconder
	  			game.accusations[:first][:accused] = second_killer_id
	  			game.accusations[:second][:accused] = killer_id

	  			first_accuser, second_accuser, first_accuser_old_score, second_accuser_old_score = get_old_scores
	  			potential_points = (civilians.length / game.current_round[:murderers].length).round

	  			game.save
	  			game.reload
					
					first_accuser_new_score, second_accuser_new_score = get_new_scores(first_accuser, second_accuser)
	  			expect(first_accuser_new_score).to eq(first_accuser_old_score + potential_points)
	  			expect(second_accuser_new_score).to eq(second_accuser_old_score + potential_points)
	  		end
	  		
	  		it "should end the round if all killers are found" do
	  			game.current_round[:murderers].each do |killer_id|
	  				seconder
	  				game.accusations[:first][:accused] = killer_id
	  				game.accusations[:second][:accused] = civilians[3].id
	  				game.save
	  			end
	  			game.reload
	  			expect(game.current_round[:completed]).to eq(true)
	  		end

	  		it "should return to winking if no seconders found" do
	  			civilian_id = civilians[1].id
	  			game.accusations[:first][:accuser] = civilian_id
	  			game.save
	  			number_of_players = game.game_sessions.length
	  			game.game_sessions.each_with_index do |session, index|
	  				next if session.id == civilian_id
  					game.accusations[:do_not_second] = session.id
  					game.save
  					game.reload
  					if index < (number_of_players - 1)
  						expect(game.accusations[:no_seconders]).to include(session.id)
  					else
  						expect(game.current_round[:phase]).to eq("winking")
  						expect(game.accusations[:no_seconders].empty?).to be(true)
  					end
	  			end
	  			expect(game.current_round[:phase]).to eq("winking")
	  		end

	  		it "should reset the round if new round is started" do

	  			new_killer_id = killer_id
		  		civilians.each do |civilian|
		  			updated_game = commit_murder(new_killer_id, civilian.id)
			  		expect(updated_game.current_round[:out_list][new_killer_id.to_s]).to include(civilian.id)
			  	end
			  	expect(game.current_round[:completed]).to be(true)
	  			game.current_round[:round_number] += 1
	  			game.save
	  			expect(game.current_round[:outed]).to eq(nil)
	  			expect(game.current_round[:murderer]).to eq(nil)
	  			expect(game.current_round[:completed]).to eq(false)
	  			game_sessions.each do |session|
	  				session.reload
	  				expect(session.scores.keys).to include(game.current_round[:round_number].to_s)
	  			end
	  			expect(game.current_round[:murderers].length).to eq(game.number_of_murderers)
	  			expect(game.current_round[:out_list].values.map(&:empty?).all? { |x| x == true}).to eq(true) 
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

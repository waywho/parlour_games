<template>
  <div class="tile">
    <div class="tile is-vertical is-7">
<!--       <div class="tile is-parent">
        <div class="tile is-child timer-tile">
          <div>{{currentGame.set.clues}}</div><div>{{currentGame.set.guessed_clues}}</div>
        </div>
      </div> -->
      <div class="tile is-parent scoring-tile">
        <div class="tile is-child timer-tile player-score">
          <b-taglist attached>
              <b-tag type="is-light" size="is-medium" class='light-tag'>{{passed}}</b-tag>
              <b-tag type="is-dark" size="is-medium">{{nominatedPlayer.player_name}}</b-tag>
              <b-tag type="is-light" size="is-medium" class='light-tag'>{{currentRoundPlayerScore}}</b-tag>
          </b-taglist>
        </div>
        <div class="tile is-child timer-tile timer-piece">
          <timer :time-limit="timeLimit" ref="gameTimer" @times-up="updateGame"></timer>
        </div>
        <div class="tile is-child timer-tile team-score" v-if="game.team_mode">
          <b-taglist attached>
            <b-tag type="is-dark" size="is-medium">{{currentTeam.name}}</b-tag>
            <b-tag type="is-light" size="is-medium" class='light-tag'>{{currentTeam.scores | sumScore}}</b-tag>
          </b-taglist>
        </div>
      </div>
      <div class='tile is-parent'>
        <div class="tile is-child">
          <div class="box clue-box">
            <span v-if="currentPlayer">{{currentClue}}</span>
            <span v-if="reveal && !currentPlayer">{{guessedClue}}</span>
          </div>
          <div class="control buttons-tile" v-if="currentPlayer">
            <b-button class="button is-dark" size="is-medium" @click="start" :disabled="noMorePass">{{playButton}}</b-button>
            <b-button class="button is-dark" size="is-medium" @click="guessed" v-if="turnStarted">Guessed</b-button>
<!--             <b-button class="button is-dark is-large" @click="updateGame">Update Game</b-button> -->
          </div>
          <form @submit.prevent="sendGuess" v-else>
            <b-field class="timer-tile">
              <b-input placeholder="enter text" v-model="guess"></b-input>
              <p class="control">
                  <b-button class="button is-dark" v-on:keyup.enter="sendGuess" native-type="submit">guess</b-button>
              </p>
            </b-field>
          </form>
        </div>
      </div>
    </div>
    <div class="tile is-parent is-vertical">
      <div calss="tile is-child score-board">
        <score-board :teams="scoreParties" :rounds="this.currentGame.rounds"></score-board>
      </div>
      <div class="tile is-child">
        <chat :chatroom-id="game.chatroom.id" ref="gameChatBox" :game-mode="true" :with-title="false" :with-input="false" :message="guess" @guessing-clue="guessingClue" class="chat-column"></chat>
      </div>
    </div>
  </div>
</template>

<script>
import timer from './timer';
import chat from './chat';
import scoreBoard from './score_board';
import axios from 'axios';
import { bus } from '../packs/application'

export default {
  props: ['game', 'gameSession', 'gameSubscription', 'timerStart', 'guessedClue', 'currentRound', 'passed'],
  components: {
    'timer': timer,
    'chat': chat,
    'score-board': scoreBoard
  },
  data: function () {
    return {
      currentGame: null,
      clues: null,
      randIndex: null,
      turnStarted: false,
      timeLimit: 60,
      reveal: false,
      noMorePass: false,
      guess: ""
    }
  },
  computed: {
    currentClue: function() {
      return this.clues[this.randIndex]
    },
    playButton: function() {
      if(this.turnStarted) {
        return "Pass"
      } else {
        return "Start"
      }
    },
    nominatedPlayer: function() {
      return _.find(this.game.game_sessions, { id: this.game.set.current_turn.nominated_player })
    },
    currentPlayer: function() {
      return this.nominatedPlayer.id == this.gameSession.id
    },
    currentRoundPlayerScore: function() {
      return this.nominatedPlayer.scores[this.currentRoundNum]
    },
    currentTeam: function() {
      return  _.find(this.game.teams, { order: this.game.set.current_turn.team })
    },
    currentRoundNum: function() {
      return this.game.set.current_round.round_number
    },
    scoreParties: function() {
      if(this.game.team_mode) {
        return this.game.teams
      } else {
        return this.game.game_sessions
      }
    }
  },
  watch: {
    timerStart (newVal, oldVal) {
      if(newVal) {
        this.turnStarted = true
        this.$refs.gameTimer.startTimer()
      } else {
        this.$refs.gameTimer.stopTimer()
      }
    },
    guessedClue (newVal, oldVal) {
      console.log('got guessed clue', newVal)
      this.currentGame.set.guessed_clues.push(newVal)
      this.updatePlayerScore(1)
      this.reveal = true
      setTimeout(() => {this.reveal = false}, 2000)
    },
    passed (newVal, oldVal) {
      return newVal
    },
    game (newVal, oldVal) {
      this.currentGame = newVal
    }
  },
  methods: {
    start: function() {
      if(this.passed >= 3) {
        return
      }
      this.randIndex = Math.floor(Math.random() * this.clues.length)
      if(!this.turnStarted) {
        this.turnStarted = true
        // this.$refs.gameTimer.startTimer()
        console.log('timer step 1 start')
        this.gameSubscription.turnStart()
      } else {
        console.log("passing clue")
        this.gameSubscription.cluesPassed(this.passed += 1)
        if(this.passed == 3) {
          this.noMorePass = true
        }
      }
    },
    resetClock: function() {

    },
    updatePlayerScore: function(incre) {
      let player_index = this.currentGame.game_sessions.indexOf(this.nominatedPlayer)
      this.currentGame.game_sessions[player_index].scores[this.currentRoundNum] += 1
      this.currentTeam.scores[this.currentRoundNum] += 1
      // this.nominatedPlayer.scores[this.currentRoundNum] += 1
      console.log('score update', this.currentGame.game_sessions[player_index].scores)
    },
    guessed: function() {
      console.log('guessed', this.clues.length)
      if(this.clues.length == 0) {
        // update game, stop clock
        this.$refs.gameTimer.stopTimer()
        this.updateGame()
      } else if (this.clues.length > 0) {
        let guessed = this.clues.splice(this.randIndex, 1)[0];
        this.gameSubscription.clueGuessed(guessed)
        this.randIndex = Math.floor(Math.random() * this.clues.length)
      }
    },
    sendGuess: function() {
      // console.log('sending message', this.guess)
      if(this.guess != null || this.guess != undefined || this.guess != "") {
        this.$refs.gameChatBox.sendMessage()
      }
      this.guess = ""
    },
    guessingClue: function(guess) {
      if(this.currentPlayer) {
        if(this.currentClue.toLowerCase() == guess.toLowerCase()) {
          this.guessed()
        }
      } else {
        return
      }
    },
    updateGame: function() {
      let player_index = this.currentGame.game_sessions.indexOf(this.nominatedPlayer)
      console.log('game update 2', this.currentGame)

      console.log('current player', this.currentPlayer)
      if (this.currentPlayer) {
        this.$store.dispatch('updateGame', {
          id: this.currentGame.id,
          set: this.currentGame.set,
          game_sessions_attributes: [
            this.currentGame.game_sessions[player_index]
          ]
        }).then(res => {
          console.log('dispatched update received', res)
          this.turnStarted = false
        })
      }

    }
  },
  created () {
    this.currentGame = this.game
    this.clues = this.game.set.clues

    console.log('game gameSubscription', this.gameSubscription)
    console.log('current player', this.currentPlayer)
  }
}
</script>

<style scoped lang="scss">

.light-tag {
  border: 1px solid #363636;
}

.scoring-tile {
  display: flex !important;
  flex-wrap: wrap !important;
}

.timer-tile {
  // height: 100px;
  // max-height: 100px;
  display: flex !important;
  justify-content: center !important;
  align-items: center !important;
}


.chat-column {
  border: 1px solid grey;
  min-height: 100% !important;
  height: 100% !important;
}

.clue-box {
  width: 35%;
  height: 60%;
  margin: auto;
  min-height: 300px;
  min-width: 250px;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 48px;
  line-height: 1 !important;
}

.buttons-tile {
  padding-top: 20px;
  margin: auto;
  height: 50px;
  max-height: 50px;
  text-align: center !important;
}

.score-board {
  height: 50%;
  min-height: 50%;
}
</style>

<template>
  <div class="tile">
    <div class="tile is-vertical is-7">
      <div class="tile is-parent">
        <div class="tile is-child timer-tile">
          <div>{{currentGame.set.clues}}</div><div>{{currentGame.set.guessed_clues}}</div>
        </div>
      </div>
      <div class="tile is-parent">
        <div class="tile is-child">
          <div class="tag">{{nominatedPlayer.team_name}}</div>
          <div class="tag is-dark is-large">{{nominatedPlayer.player_name}}</div>
          <div class="tag">{{currentRoundPlayerScore}}</div>
        </div>
        <div class="tile is-child timer-tile">
          <timer :time-limit="timeLimit" ref="gameTimer" @times-up="updateGame"></timer>
        </div>
      </div>
      <div class='tile is-parent'>
        <div class="tile is-child">
          <div class="box clue-box">
            <span v-if="currentPlayer">{{currentClue}}</span>
            <span v-if="reveal && !currentPlayer">{{guessedClue}}</span>
          </div>
          <div class="control buttons-tile" v-if="currentPlayer">
            <b-button class="button is-dark is-large" @click="start">{{playButton}}</b-button>
            <b-button class="button is-dark is-large" @click="guessed">Guessed</b-button>
<!--             <b-button class="button is-dark is-large" @click="updateGame">Update Game</b-button> -->
          </div>
        </div>
      </div>
    </div>
    <div class="tile is-parent is-vertical">
      <div calss="tile is-child score-board">
        <score-board :teams="this.currentGame.teams" :rounds="this.currentGame.rounds"></score-board>
      </div>
      <div class="tile is-child">
        <chat :chatroom-id="game.chatroom.id" :game-mode="true" :with-title="false" class="chat-column"></chat>
      </div>
    </div>
  </div>
</template>

<script>
import timer from './timer'
import chat from './chat'
import scoreBoard from './score_board'
import axios from 'axios'

export default {
  props: ['game', 'gameSession', 'gameSubscription', 'timerStart', 'guessedClue', 'currentRound'],
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
      roundStart: false,
      passed: 0,
      timeLimit: 60,
      reveal: false
    }
  },
  computed: {
    currentClue: function() {
      return this.clues[this.randIndex]
    },
    playButton: function() {
      if(this.roundStart) {
        return "Pass"
      } else {
        return "Start"
      }
    },
    nominatedPlayer: function() {
      return _.find(this.currentGame.game_sessions, { id: this.currentGame.set.current_turn.nominated_player })
    },
    currentPlayer: function() {
      return this.nominatedPlayer.id == this.gameSession.id
    },
    currentRoundPlayerScore: function() {
      return this.nominatedPlayer.scores[this.currentRoundNum]
    },
    currentTeam: function() {
      return this.currentGame.set.current_turn.team
    },
    currentRoundNum: function() {
      return this.currentGame.set.current_round.round_number
    }
  },
  watch: {
    timerStart (newVal, oldVal) {
      if(newVal) {
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
    game (newVal, oldVal) {
      this.currentGame = newVal
    }
  },
  methods: {
    start: function() {
      this.randIndex = Math.floor(Math.random() * this.clues.length)
      if(!this.roundStart) {
        this.roundStart = true
        // this.$refs.gameTimer.startTimer()
        console.log('timer step 1 start')
        this.gameSubscription.timerStart()
      } else {
        this.passed += 1
      }
    },
    resetClock: function() {

    },
    updatePlayerScore: function(incre) {
      let player_index = this.currentGame.game_sessions.indexOf(this.nominatedPlayer)
      this.currentGame.game_sessions[player_index].scores[this.currentRoundNum] += 1
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
    updateGame: function() {
      let player_index = this.currentGame.game_sessions.indexOf(this.nominatedPlayer)
      console.log('game update 2', this.currentGame)
      this.$refs.gameTimer.stopTimer()
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
        })
      }

    }
  },
  created () {
    this.currentGame = this.game
    this.clues = this.game.set.clues
    this.$store.dispatch('reloadGameSession', {player: {value: this.gameSession.player_name}, gameId: {value: this.game.id}, user: ""})

    console.log('game gameSubscription', this.gameSubscription)
    console.log('current player', this.currentPlayer)
  }
}
</script>

<style scoped>
.timer-tile {
  height: 70px;
  max-height: 70px;
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

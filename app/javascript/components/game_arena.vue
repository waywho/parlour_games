<template>
  <div class="tile">
    <div class="tile is-vertical is-7">
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
      <div class='tile is-parent is-vertical game-center'>
        <div class="tile is-child card-pot">
        <div class="card-stack">
          <game-paper :clue="currentClue" :withInput="false"></game-paper>
          <div v-if="reveal && !currentPlayer" class="clue-word">{{guessedClue}}</div>
        </div>
        </div>

        <div class="control buttons-tile tile is-child" v-if="currentPlayer">
          <b-button class="button is-dark" size="is-medium" @click="start" :disabled="noMorePass">{{playButton}}</b-button>
          <b-button class="button is-dark" size="is-medium" @click="guessed" v-if="turnStarted">Guessed</b-button>
<!--             <b-button class="button is-dark is-large" @click="updateGame">Update Game</b-button> -->
        </div>

        <form v-if="useChat" @submit.prevent="sendGuess" class="tile is-child" v-else>
          <b-field class="timer-tile">
            <b-input placeholder="enter text" v-model="guess"></b-input>
            <p class="control">
                <b-button class="button is-dark" v-on:keyup.enter="sendGuess" native-type="submit">guess</b-button>
            </p>
          </b-field>
        </form>

      </div>
    </div>
    <div class="tile is-parent is-vertical">
      <div class="tile is-child title is-5 section-line">
        Teams
      </div>
      <div class="tile is-child">
        <div v-for="team in game.teams" :key="team.id" class="tags are-medium">
          <div class="tag is-light"><b>{{team.name}}:</b></div> <player v-for="session in team.game_sessions" :key="session.id" :game-session="session" :currentHost="currentHost" :class="[nominatedPlayer.id == session.id ? 'is-dark' : 'is-light']"></player>
        </div>
      </div>
      <div calss="tile is-child score-board">
        <div class="tile is-child title is-5 section-line">
          Score Board
        </div>
        <score-board :teams="scoreParties" :rounds="this.currentGame.rounds"></score-board>
      </div>
      <div v-if="useChat"  class="tile is-child">
        <chat :chatroom-id="game.chatroom.id" ref="gameChatBox" :game-mode="true" :with-title="false" :with-input="false" :message="guess" @guessing-clue="guessingClue" class="chat-column"></chat>
      </div>
    </div>
  </div>
</template>

<script>
import timer from './timer'
import chat from './chat'
import scoreBoard from './score_board'
import axios from 'axios'
import player from './player'
import gamePaper from './game_paper'
import { bus } from '../packs/application'

export default {
  props: {
    'game': {
      type: Object,
      required: false,
    }, 
    'gameSession': {
      type: Object,
      required: false,
    }, 
    'gameSubscription': {
      type: Object,
      required: false,
    }, 
    'turnStart': {
      type: Boolean,
      required: false,
    }, 
    'guessedClue': {
      type: String,
      required: false,
    },
    'passed': {
      type: Number,
      required: false,
    }, 
    'useChat': {
      type: Boolean,
      required: false,
      default: false
    },
    'currentHost': {
      type: Boolean,
      required: false
    },
    'currentRound': {
      type: Object,
      required: false
    }
  },
  components: {
    'timer': timer,
    'chat': chat,
    'score-board': scoreBoard,
    'player': player,
    'game-paper': gamePaper
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
    currentClue: {
      get: function() {
        return this.clues[this.randIndex]
      },
      set: function(newVal) {
        return newVal
      }
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
    },
  },
  watch: {
    turnStart (newVal) {
      console.log('what command? starting turn?', newVal)
      this.turnStarted = newVal
    },
    turnStarted (newVal, oldVal) {
      console.log('starting turn?', newVal)
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
    passed (newVal, oldVal) {
      return newVal
    },
    // game (newVal, oldVal) {
    //   this.currentGame = newVal

    // },
    currentRound(newVal, oldVal) {
      if(newVal.name != oldVal.name) {
        this.resetClock()
      }
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
      this.$refs.gameTimer.resetTimer()
    },
    updatePlayerScore: function(incre) {
      let player_index = this.currentGame.game_sessions.indexOf(this.nominatedPlayer)
      this.nominatedPlayer.scores[this.currentRoundNum] += 1
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
      console.log('game update 2', this.currentGame)
      this.$refs.gameTimer.stopTimer()

      console.log('current player', this.currentPlayer)

      if (this.currentPlayer) {
        this.$store.dispatch('updateGame', {
          id: this.currentGame.id,
          set: this.currentGame.set,
          game_sessions_attributes: [
            this.nominatedPlayer
          ],
          teams_attributes: [
            this.currentTeam
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

    bus.$on('gameUpdate', (game) => {
      this.currentGame = game
      this.turnStarted = false
      this.resetClock()
    })

    console.log('game gameSubscription', this.gameSubscription)
    console.log('current player', this.currentPlayer)
  }
}
</script>

<style scoped lang="scss">

.game-center {
  min-height: 500px;
}

.clue-word {
  text-align: center;
  position: absolute;
  top: 0;
  z-index: 99;
  font-size: 30px;
  font-weight: bold;
  width: 100%;
  height: 100%;
  padding-top: 40%;
}

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

.section-line {
  border-bottom: 1px solid #636363
}
</style>

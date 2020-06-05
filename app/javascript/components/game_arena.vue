<template>
  <div class="tile">
    <div class="tile is-vertical is-8">
      <div class="tile is-parent">
        <div class="tile is-child timer-tile">
          <div>{{currentGame.set.clues}}</div><div>{{currentGame.set.guessed_clues}}</div>
        </div>
      </div>
      <div class="tile is-parent">
        <div class="tile is-child">
          <div class="tag is-dark is-large">{{nominatedPlayer.player_name}}</div>
        </div>
        <div class="tile is-child timer-tile">
          <timer :time-limit="timeLimit" ref="gameTimer"></timer>
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
          </div>
        </div>
      </div>
    </div>
    <div class="tile is-parent is-vertical">
      <div calss="tile is-child score-board">
        <div>scor</div>
        <div>asdf</div>
        <div>asdf</div>
        <div>asdf</div>
        <div>asdf</div>
      </div>
      <div class="tile is-child">
        <chat :chatroom-id="game.chatroom.id" :game-mode="true" :with-title="false" class="chat-column" :times-up="updateGameSet"></chat>
      </div>
    </div>
  </div>
</template>

<script>
import timer from './timer'
import chat from './chat'

export default {
  props: ['game', 'gameSession', 'gameSubscription', 'timerStart', 'guessedClue'],
  components: {
    'timer': timer,
    'chat': chat
  },
  data: function () {
    return {
      currentGame: null,
      clues: null,
      randIndex: null,
      roundStart: false,
      passed: 0,
      timeLimit: 60,
      reveal: false,
      playerScore: 0
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
    currentTeam: function() {
      return this.currentGame.set.current_turn.team
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
      this.reveal = true
      setTimeout(() => {this.reveal = false}, 2000)

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
    guessed: function() {
      if(this.clues.length == 0) {
        // update game, stop clock
        this.$refs.gameTimer.stopTimer()

      } else if (this.clues.length > 0) {
        let guessed = this.clues.splice(this.randIndex, 1)[0];
        this.playerScore += 1
        this.gameSubscription.clueGuessed(guessed)
        this.randIndex = Math.floor(Math.random() * this.clues.length)
      }
    },
    updateGameSet: function() {

      this.$store.dispatch('updateGameSet', {gameId: this.currentGame.id, setData: this.currentGame.set}).then(res => {
        console.log('dispatched update received', res)
      })
    }
  },
  created () {
    this.currentGame = this.game
    this.clues = this.game.set.clues
    this.$store.dispatch('reloadGameSession', {player: {value: this.gameSession.player_name}, gameId: {value: this.game.id}})
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

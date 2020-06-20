<template>
  <div class="columns is-gapless">
    <div class="column is-two-thrids-desktop is-half-tablet">
      <div class="columns is-mobile is-centered is-vcentered">
        <div class="column center-tile is-full-size-mobile is-full-size-desktop">
          <game-header class="game-header" :game="game" :game-image="gameImage"></game-header>
          <div>
            <div v-if="!game.ended"><b>Round: </b>
              <b-tooltip :label="currentRound.instructions" type="is-dark"
                position="is-bottom" multilined size="is-medium">
                <div class="tag is-dark is-small instruction-button">
                    {{currentRound.name}}
                </div>
              </b-tooltip>
            </div>
            <div><b>Number of clues {{ game.set.guessed_clues.length > 0 ? "left" : ""}}:</b> {{clueNum}} </div>
          </div>
        </div>
      </div>
      <div class="columns is-mobile is-centered is-vcentered">
        <div class="column center-tile is-full-size-mobile is-full-size-tablet is-full-size-desktop">
          <player-turn :passing="true" :game="currentGame" :nominated-player="nominatedPlayer" :current-player="currentPlayer"></player-turn>
          
          <timer class="mx-4" :time-limit="timeLimit" ref="gameTimer" @times-up="completeTurn"></timer>
      
          <b-taglist attached v-if="game.team_mode">
            <b-tag type="is-dark" size="is-medium">{{currentTeam.name}}</b-tag>
            <b-tag type="is-light" size="is-medium" class='light-tag'>{{currentTeam.scores | sumScore}}</b-tag>
          </b-taglist>
        </div>
      </div>
      <div class="columns is-mobile is-centered">
        <div class="column is-four-fifths-tablet is-four-fifths-desktop">
          <div class="card-pot">
            <div class="card-stack">
              <game-paper :clue="showClue" :withInput="false"></game-paper>
            </div>
          </div>
        </div>
      </div>
      <div class="columns is-multiline is-centered" v-if="currentPlayer">
        <div class="column is-three-fifths-desktop control has-text-centered">
          <b-button class="button is-dark" size="is-medium" @click="start" :disabled="noMorePass">{{playButton}}</b-button>
          <b-button class="button is-dark" size="is-medium" @click="guessed" v-if="turnStarted">Guessed</b-button>
<!--             <b-button class="button is-dark is-large" @click="updateGame">Update Game</b-button> -->
        </div>

        <div class="column is-three-fifths-desktop" v-if="useChat">
          <form  @submit.prevent="sendGuess" class="">
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
    <div class="column is-one-third-tablet is-half-tablet">
      <div class="columns is-multiline">
        <div class="column is-full">
          <div class="title is-5 section-line">
            Teams
          </div>
        </div>
        <div class="column is-full">
          <div v-for="team in game.teams" :key="team.id" class="tags are-medium">
            <span class="tag is-light"><b>{{team.name}}:</b></span> <player v-for="session in team.game_sessions" :key="session.id" :game-session="session" :currentHost="currentHost" :class="[nominatedPlayer.id == session.id ? 'is-dark' : 'is-light']"></player>
          </div>
        </div>
        <div class="column is-full">
          <div class="title is-5 section-line">
              Score Board
          </div>
        </div>
        <div class="column is-full">
          <score-board :teams="scoreParties" :rounds="this.currentGame.rounds" class="is-narrow"></score-board>
        </div>
        <div class="column is-full">
          <div v-if="useChat"  class="tile is-child">
            <chat :chatroom-id="game.chatroom.id" ref="gameChatBox" :game-mode="true" :with-title="false" :with-input="false" :message="guess" @guessing-clue="guessingClue" class="chat-column"></chat>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import timer from './timer';
import chat from './chat';
import scoreBoard from './score_board';
import axios from 'axios';
import player from './player';
import gamePaper from './game_paper';
import { bus } from '../packs/application';
import gameHeader from './game_header';
import fishbowlImage from '../assets/fish-bowl-glow.png';
import playerTurn from './player_turn';
import gameBehaviours from '../mixins/gameBehaviours'

export default {
  props: {
    game: {
      type: Object,
      required: false,
    }, 
    gameSession: {
      type: Object,
      required: false,
    }, 
    gameSubscription: {
      type: Object,
      required: false,
    },
    useChat: {
      type: Boolean,
      required: false,
      default: false
    },
    currentHost: {
      type: Boolean,
      required: false
    },
    currentRound: {
      type: Object,
      required: false
    }
  },
  mixins: [gameBehaviours],
  components: {
    'timer': timer,
    'chat': chat,
    'score-board': scoreBoard,
    'player': player,
    'game-paper': gamePaper,
    'game-header': gameHeader,
    'player-turn': playerTurn
  },
  data: function () {
    return {
      gameImage: fishbowlImage,
      currentGame: null,
      clues: null,
      randIndex: null,
      turnStarted: false,
      timeLimit: 60,
      guess: "",
      guessedClue: null,
      clueNum: 0
    }
  },
  computed: {
    showClue: function() {
      if(this.currentPlayer) {
        return this.currentClue
      } else {
        return this.guessedClue
      }
    },
    currentClue: function() {
      return this.currentGame.set.clues[this.randIndex]
    },
    playButton: function() {
      if(this.turnStarted) {
        return "Pass"
      } else {
        return "Start"
      }
    },
    currentTeam: function() {
      return  _.find(this.game.teams, { order: this.game.set.current_turn.team })
    },
    scoreParties: function() {
      if(this.game.team_mode) {
        return this.game.teams
      } else {
        return this.game.game_sessions
      }
    },
    noMorePass: function() {
      return this.currentGame.set.current_turn.passed >= 3
    }
  },
  watch: {
    game(newVal, oldVal) {
      this.currentGame = newVal
      this.clueNum = this.currentGame.set.clues.length
    },
    currentRound(newVal, oldVal) {
      if(newVal.name != oldVal.name) {
        this.resetClock()
      }
    }
  },
  methods: {
    start: function() {
      if(this.currentGame.set.current_turn.passed >= 3) {
        console.log('more than 3')
        return
      }
      this.randIndex = Math.floor(Math.random() * this.currentGame.set.clues.length)
      if(!this.turnStarted) {
        this.turnStarted = true
        // this.$refs.gameTimer.startTimer()
        console.log('timer step 1 start')
        this.gameSubscription.turnStart()
      } else {
        console.log("passing clue")
        this.currentGame.set.current_turn.passed += 1
        this.updateGame()
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
      console.log('guessed 1', this.currentGame.set.clues.length)

      let guessed = this.currentGame.set.clues.splice(this.randIndex, 1)[0];
      this.currentGame.set.guessed_clues.push(guessed)
      this.updatePlayerScore(1)
      this.clueNum -= 1
      this.gameSubscription.clueGuessed(guessed)

      console.log('guessed 2', this.currentGame.set.clues.length)

      if(this.currentGame.set.clues.length == 0) { 
        this.$refs.gameTimer.stopTimer()
        this.completeTurn()
      } else {
        this.randIndex = Math.floor(Math.random() * this.currentGame.set.clues.length)
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
    completeTurn: function() {
      this.currentGame.set.current_turn.completed = true
      this.turnStarted = false
      this.resetClock()
      this.updateGame()

    },
    updateGame: function() {
      console.log('game update 2', this.currentGame)
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
    // this.clues = this.game.set.clues
    this.clueNum = this.game.set.clues.length
    if(this.game.set.options.time_limit) {
      this.timeLimit = this.game.set.options.time_limit
    }
    
    bus.$on('startTimer', () => {
      this.$refs.gameTimer.startTimer()
    })

    bus.$on('showGuessed', (clue) => {
      if(!this.currentPlayer) {
        this.updatePlayerScore(1)
        this.guessedClue = clue
        this.clueNum -= 1
        setTimeout(() => {
          this.guessedClue = ""
        }, 2000)
      }

    })

    console.log('game gameSubscription', this.gameSubscription)
    console.log('current player', this.currentPlayer)
  }
}
</script>

<style scoped lang="scss">

.no-margin {
  margin-bottom: -0.5rem;
}

.game-header {
  max-height: 70px;
}

.clue-word {
  text-align: center;
  position: absolute;
  top: 0;
  z-index: 20;
  font-size: 30px;
  font-weight: bold;
  width: 100%;
  height: 100%;
  padding-top: 40%;
}

.chat-column {
  border: 1px solid grey;
  min-height: 100% !important;
  height: 100% !important;
}

.section-line {
  border-bottom: 1px solid #636363
}
</style>

<template>
  <div class="columns">
    <div class="column">
      <div class="columns is-multiline">
        <div class="column center-tile is-full-size-mobile is-full-size-desktop">
          <game-header class="game-header" :game="game"></game-header>
        </div>
        <div class="column is-full">
          <div class="columns is-mobile is-centered is-vcentered">
            <div class="column center-tile is-full-size-mobile is-full-size-tablet is-full-size-desktop">
              <player-turn :passing="false" :game="currentGame" :nominated-player="nominatedPlayer" :current-player="currentPlayer"></player-turn>
            </div>
          </div>
        </div>

        <div class="column is-full letter-arena center-tile">
          <fitty :options="options" :class="'center-tile'">
            <template v-slot:content>

              {{showPlay}}

            </template>
          </fitty>
      
        </div>
        <div class="column is-full" v-if="currentPlayer">
          <div class="buttons">
            <b-button type="is-dark" v-for="(l, index) in letters" @click="playLetter(l)" :value="l" :key="index">{{l}}</b-button>
          </div>
        </div>
        <div class="column is-full">
          <div class="buttons">
             <b-button type="is-dark" @click="wordComplete" :disabled="!disableChallenge">Challenge World Complete</b-button>
            <b-button type="is-dark" @click="spelling" :disabled="!disableChallenge">Challenge Spelling</b-button>
          </div>
        </div>
      </div>
    </div>
    <div class="column">
      <div class="columns is-multiline">
        <!-- <div v-if="currentGame.set.word_definition"class="column is-full">
          <div>{{currentGame.set.word_definition}}</div>
        </div> -->
        
        <div class="column is-full">
            <div class="title is-5 section-line">
              Players
            </div>
        </div>
        <div class="column is-full" v-for="session in currentGame.game_sessions" :key="session.id" >
          <player :game-session="session" :currentHost="currentHost" :class="[nominatedPlayer.id == session.id ? 'is-dark' : 'is-light']"></player>: <div class="tag is-dark" v-for="letter in game.set.player_ghosts[session.id]">{{letter}}</div>
        </div>
        <div class="column is-full">
          <div class="title is-5 section-line">
            Score Board
          </div>
        </div>
        <div class="column is-full">
          <score-board :teams="currentGame.game_sessions" :rounds="this.currentGame.set.rounds_played" class="is-narrow"></score-board>
        </div>
      </div>
    </div>
    <round-notice :current-round="currentRound" :game="game" :show-scores="gameComplete" :enable-next-round="gameComplete && currentHost" :scoring-parties="game.game_sessions"></round-notice>
  </div>
</template>

<script>
import scoreBoard from './score_board';
import player from './player';
import gameHeader from './game_header';
import playerTurn from './player_turn';
import gameBehaviours from '../mixins/gameBehavioursMixin'
import roundNotice from './round_notice';

export default {
  props: {
    game: {
      type: Object,
      required: true
    },
    gameSession: {
      type: Object,
      required: false,
    },
    currentHost: {
      type: Boolean,
      required: false
    },
  },
  mixins: [gameBehaviours],
  data: function () {
    return {
      options: {
        minSize: 8,
        maxSize: 120
      },
      currentGame: null,
      playWord: [],
      letters: ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    }
  },
  components: {
    'round-notice': roundNotice,
    'player': player,
    'score-board': scoreBoard,
    'game-header': gameHeader,
    'player-turn': playerTurn
  },
  computed: {
    disableChallenge: function() {
      console.log(this.currentGame.set.play_word.length)
      console.log(this.currentGame.options.min_word_length)
      return this.currentGame.set.play_word.length >= this.currentGame.options.min_word_length
    },
    showPlay: function() {
      return this.currentGame.set.play_word.join("")
    },
    roundCompleted: function() {
      return this.currentGame.set.current_round.completed
    },
    currentRound: function() {
      console.log('word def',this.currentGame.set.word_definition )
      // let word_def = JSON.parse(this.currentGame.set.word_definition)
      if(this.currentGame.set.current_round.completed) {
        return {
          name: "End of Round",
          instructions: ""
        }
      } else if(this.currentGame.turn_order.challenge.results != null & this.currentGame.turn_order.challenge.results != undefined) {
        return {
          name: this.currentGame.turn_order.challenge.results.word,
          instructions: this.currentGame.turn_order.challenge.results.outcome
        }
      } else {
        return {
          name: "",
          instructions: ""
        }
      }
    },
    gameComplete: function() {
      return this.currentGame.set.current_round.completed
    }
  },
  methods: {
    nextRound: function() {
      if(this.roundCompleted) {
        this.currentGame.set.current_round.round_number += 1
        if(this.currentHost) {
          this.updateGame()
        };
      }
      
    },
    playLetter: function(e) {
      console.log("letter", e)
      this.currentGame.set.play_word.push(e)
      if(this.currentPlayer) {
        var gameData = {
          id: this.currentGame.id,
          play_word: this.currentGame.set.play_word
          
          // game_sessions_attributes: [
          //   this.nominatedPlayer
          // ]
        }
        this.updateGame(gameData)
      };
    },
    wordComplete: function() {
      var gameData = {
        id: this.currentGame.id,
        challenge: {
          type: 'word_complete',
          challenger: this.gameSession.id,
          challenge_results: null
        }
      }
      this.updateGame(gameData)
    },
    spelling: function() {
      var gameData = {
        id: this.currentGame.id,
        challenge: {
          type: 'spelling',
          challenger: this.gameSession.id,
          challenge_results: null
        }
      }
      this.updateGame(gameData)
    },
    updateGame: function(gameData) {
      console.log('game update 2', this.currentGame)

      this.$store.dispatch('updateGame', gameData).then(res => {
        console.log('dispatched update received', res)
      })
    }
  },
  created () {
    this.currentGame = this.game
    
  }
}
</script>

<style scoped lang="scss">
.letter-arena {
  min-height: 350px;
  max-height: 350px;
  min-width: 375px;
  max-width: 684px;
}

.tags.are-xlarge > .tag {
  font-size: 3em;
}
</style>

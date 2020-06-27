<template>
  <div class="columns">
    <div class="column">
      <div class="columns is-multiline">
        <div class="column center-tile is-full-size-mobile is-full-size-desktop">
          <game-header class="game-header" :game="game" :game-image="gameImage"></game-header>
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
      </div>
    </div>
    <div class="column">
      <div class="columns is-multiline">
        <!-- <div v-if="currentGame.set.word_definition"class="column is-full">
          <div>{{currentGame.set.word_definition}}</div>
        </div> -->
        <div class="column is-full buttons">
          <b-button type="is-dark" @click="nextRound" :disabled="!roundCompleted">Next Round</b-button>
          <!-- TODO: not implemented at the moment, implement later -->
          <b-button v-if="false" type="is-dark" @click="() => {this.showChallenge = true}">Challenge</b-button>
        </div>
        <div class="column is-full" v-show="showChallenge">
          <b>Possible Words:</b>{{challengeResults}}
        </div>
        <div class="column is-full">
            <div class="title is-5 section-line">
              Players
            </div>
        </div>
        <div class="column is-full tags" v-for="session in currentGame.game_sessions" :key="session.id" >
          <player :game-session="session" :currentHost="currentHost" :class="[nominatedPlayer.id == session.id ? 'is-dark' : 'is-light']"></player>: <div class="tag is-dark" v-for="letter in game.set.player_ghosts[session.id]">{{letter}}</div>
        </div>
        <div class="column is-full">
          <div class="title is-5 section-line">
            Score Board
          </div>
        </div>
        <div class="column is-full">
          <score-board :teams="currentGame.game_sessions" :rounds="this.currentGame.rounds" class="is-narrow"></score-board>
        </div>
      </div>
    </div>
    <round-notice :current-round="currentRound" :game-image="gameImage"></round-notice>
  </div>
</template>

<script>
import scoreBoard from './score_board';
import player from './player';
import ghostImage from '../assets/smileys-filled.png';
import gameHeader from './game_header';
import playerTurn from './player_turn';
import gameBehaviours from '../mixins/gameBehaviours'
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
      showChallenge: false,
      gameImage: ghostImage,
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
    showPlay: function() {
      return this.currentGame.set.play_word.join("")
    },
    roundCompleted: function() {
      return this.currentGame.set.current_round.completed
    },
    currentRound: function() {
      console.log('word def',this.currentGame.set.word_definition )
      // let word_def = JSON.parse(this.currentGame.set.word_definition)
      if(this.currentGame.set.word_definition != null & this.currentGame.set.word_definition != undefined) {
        return {
          name: this.currentGame.set.word_definition.word,
          instructions: this.currentGame.set.word_definition.defs
        }
      } else {
        return {
          name: '',
          instructions: ''
        }
      }
    },
    challengeResults: function() {
      if(this.currentGame.set.challenge_results != null & this.currentGame.set.challenge_results != undefined) {
        return this.currentGame.set.challenge_results.join(", ")
      }
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
        this.updateGame()
      };
    },
    updateGame: function() {
      console.log('game update 2', this.currentGame)

      this.$store.dispatch('updateGame', {
        id: this.currentGame.id,
        set: this.currentGame.set,
        turn_order: this.currentGame.turn_order,
        game_sessions_attributes: [
          this.nominatedPlayer
        ]
      }).then(res => {
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

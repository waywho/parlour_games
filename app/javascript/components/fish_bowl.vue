<template>
  <div class="tile is-ancestor is-vertical">
    <div class="tile">
      <div class="tile is-parent is-7">
        <div class="tile is-child">
          <h2 class="title is-3">{{game.name}}: Game {{game.id}}</h2>
        </div>
      </div>
      <div class="tile is-parent">
        <div class="tile is-child">
          <div v-if="!game.ended"><b>Round: </b>
            <b-tooltip :label="currentRound.instructions" type="is-dark"
              position="is-bottom" multilined size="is-medium">
              <div class="tag is-dark is-small instruction-button">
                  {{currentRound.name}}
              </div>
            </b-tooltip>
          </div>
          <div class=""><b>Number of Clues Left:</b> {{numClues}} </div>
        </div>
      </div>
    </div>
    <component :is="currentComponent" :game="game" :game-session="gameSession" :current-host="currentHost" :game-subscription="gameSubscription" :turn-start="turnStart" :guessed-clue="guessedClue" :passed="passed" :current-round="currentRound"></component>
    <round-notice :current-round="currentRound"></round-notice>
  </div>
</template>

<script>
import clues from './clues';
import gameArena from './game_arena';
import endGame from './end_game';
import roundNotice from './round_notice';

export default {
	props: ['game', 'gameSession', 'currentHost', 'gameSubscription', 'turnStart', 'guessedClue', 'passed'],
  components: {
    'clues': clues,
    'game-arena': gameArena,
    'end-game': endGame,
    'round-notice': roundNotice
  },
  data: function () {
    return {
      newRound: false,
      gameComponents: {
        0: {component: 'clues'},
        1: {component: 'gameArena'},
        2: {component: 'gameArena'},
        3: {component: 'gameArena'}
      },
      clueNum: this.game.set.clues.length
    }
  },
  computed: {
    numClues: {
      get: function() {
        return this.clueNum
      },
      set: function(newVal) {
        console.log('got new val', newVal)
        this.clueNum = newVal
      }
    },
    currentComponent: function() {
      // console.log('current round', this.game.set.current_round)
      // console.log('round name', this.game.rounds[this.game.set.current_round.round_number])
      if(this.game.ended) {
        return 'end-game'
      } else if(this.game.set.current_round.round_number != null && this.game.set.current_round.round_number > 0) {
        return 'game-arena'
      } else {
        return 'clues'
      }
      // return this.game.set.rounds[this.game.set.current_round.round_number].name.toLowerCase()
    },
    currentRound: function() {
      return this.game.rounds[this.game.set.current_round.round_number]
    }
  },
  watch: {
    guessedClue(newVal) {
      console.log('got guessed clue', newVal)
      this.numClues -= 1
    }
  },
  created() {
    
  }
}
</script>

<style scoped>
.instruction-button {
  margin-left: 1em;
  cursor: pointer;
}
</style>

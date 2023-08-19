<template>
  <span class="">
    <component  :is="currentComponent" 
                :game="game" 
                :game-session="gameSession" 
                :scoring-parties="game.teams" 
                :current-host="currentHost" 
                :game-subscription="gameSubscription" 
                :current-round="currentRound" 
                :game-image="gameImage">
    </component>
    <round-notice :current-round="currentRound" :game="game"></round-notice>
  </span>
</template>

<script>
import clues from './clues';
import gameArena from './game_arena';
import endGame from './end_game';
import roundNotice from './round_notice';
import gameBehaviours from '../mixins/gameBehavioursMixin';
import { bus } from '../packs/application';

export default {
	props: ['game', 'gameSession', 'currentHost', 'gameSubscription'],
  components: {
    'clues': clues,
    'game-arena': gameArena,
    'end-game': endGame,
    'round-notice': roundNotice
  },
  mixins: [gameBehaviours],
  data: function () {
    return {
      newRound: false,
      gameComponents: {
        0: {component: 'clues'},
        1: {component: 'gameArena'},
        2: {component: 'gameArena'},
        3: {component: 'gameArena'}
      },
      clueNum: 0
    }
  },
  computed: {
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
  created() {
    this.clueNum = this.game.set.clues.length
    bus.$on('showGuessed', (clue) => {
      this.clueNum -= 1
    })
  }
}
</script>

<style scoped>
.instruction-button {
  margin-left: 1em;
  cursor: pointer;
}
</style>

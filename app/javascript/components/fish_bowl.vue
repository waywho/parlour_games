<template>
  <div class="tile is-ancestor is-vertical">
    <div class="tile is-parent">
      <div class="tile is-8 is-child">
        <h2 class="title is-3">{{game.name}}: Game {{game.id}}</h2>
      </div>
      <div class="tile is-4 is-child">
        <div class=""><i><b>Round:</b> {{currentRound.name}}</i>
          <b-tooltip :label="currentRound.instructions" type="is-dark"
            position="is-bottom" multilined is-large>
            <button class="button is-dark is-small instruction-button">
                Instructions
            </button>
          </b-tooltip>
        </div>
          
          <div class=""><b>Player:</b> {{gameSession.player_name}} </div>
      </div>
    </div>
    <component :is="currentComponent" :game="game" :game-session="gameSession" :current-host="currentHost" :game-subscription="gameSubscription" :timer-start="timerStart" :guessed-clue="guessedClue"></component>
  </div>
</template>

<script>
import clues from './clues'
import gameArena from './game_arena'
export default {
	props: ['game', 'gameSession', 'currentHost', 'gameSubscription', 'timerStart', 'guessedClue'],
  components: {
    'clues': clues,
    'gameArena': gameArena
  },
  data: function () {
    return {
      gameComponents: {
        0: {component: 'clues'},
        1: {component: 'gameArena'},
        2: {component: 'gameArena'},
        3: {component: 'gameArena'}

      }
    }
  },
  computed: {
    currentComponent: function() {
      console.log('current round', this.game.set.current_round)
      console.log('round name', this.game.rounds[this.game.set.current_round.round_number])
      if(this.game.set.current_round.round_number != null && this.game.set.current_round.round_number > 0) {
        return 'gameArena'
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
    
  }
}
</script>

<style scoped>

</style>

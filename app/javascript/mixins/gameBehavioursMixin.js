import { mapGetters } from 'vuex';

export default {
	computed: {
    ...mapGetters({
      gameInfo: 'gameInfo'
    }),
    gameImage: function() {
      return this.$store.getters.gameInfo(this.game.name).glow
    },
		nominatedPlayer: function() {
      return _.find(this.game.game_sessions, { id: this.game.turn_order.current_turn.nominated_player })
    },
    currentPlayer: function() {
      return this.nominatedPlayer.id == this.gameSession.id
    },
    currentRoundNum: function() {
      return this.game.set.current_round.round_number
    }
	},
	 watch: {
    game(newVal, oldVal) {
    	console.log('got new val game', newVal)
      this.currentGame = newVal
    }
  }
}
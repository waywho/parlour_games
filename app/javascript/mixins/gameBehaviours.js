export default {
	computed: {
		nominatedPlayer: function() {
      return _.find(this.game.game_sessions, { id: this.game.set.current_turn.nominated_player })
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
    	console.log('got new val game')
      this.currentGame = newVal
    }
  }
}
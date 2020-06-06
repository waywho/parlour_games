export default {
	methods: {
		goToGame: function (comp, id) {
			this.$router.push({name: 'game', params: { gameComponent: this.$options.filters.camelToUnderscore(comp), game_id: id.toString() }})
		}
	}
}
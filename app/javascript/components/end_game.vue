<template>
  <div class="tile">
    <score-board :teams="game.teams" :rounds="game.rounds"></score-board>

  </div>
</template>

<script>
import scoreBoard from './score_board'
export default {
  props: ['game'],
  data: function () {
    return {
      
    }
  },
  components: {
    'score-board': scoreBoard
  },
  methods: {
    reMatch: function() {
    let newGame = this.game
    delete newGame.id
    parlourAxios.post('/games', {game: {name: newGame} })
      .then(res => {
        const host = res.data.hosts.filter(host => {
          return host.playerable_id == this.$store.getters.currentUser.id
        })[0]
        localStorage.setItem('game_session', JSON.stringify(host))
        this.currentGameId = res.data.id 
        this.currentGameName = this.$options.filters.camelToUnderscore(res.data.name)
      })   
    },
  },
  created () {
    
    
  }
}
</script>

<style scoped>

</style>

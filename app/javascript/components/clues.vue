<template>
  <div class="tile">
    <div v-if="!cluesSubmitted" class="tile is-parent wrap-tile">
      <div class="tile is-child is-2 box clue-box" v-for="(clue, index) in clues" :key="index">
        <textarea class="textarea clue-input" placeholder="enter a clue" rows="10" v-model="clue.value"></textarea>


      </div>
      <b-button class="clue-button" type="is-dark" @click="submitClues" expanded>Add Clues into the FishBowl</b-button>
    </div>
    <div v-else>
      Waiting to start the game
      <b-button type="is-dark" @click="startGame" expanded v-if="currentHost">Start Game</b-button>
    </div>
    
  </div>
</template>

<script>
import gameAxios from '../axios/axios_game_update.js';

export default {
	props: ['game', 'currentHost', 'gameSession'],
  components: {
    
  },
  data: function () {
    return {
      currentGame: null,
      clues: [],
      clueNumbers: 5
    }
  },
  computed: {
    cluesSubmitted: function() {
      if(_.includes(this.currentGame.set.players_gone, this.gameSession.id)) {
        return true
      } else {
        return false
      }
    }
  },
  methods: {
    startGame: function() {
      let startGame = false
      if(this.currentGame.set.players_gone.length == this.currentGame.game_sessions.length) {
        startGame = true
      } else {
        const startGame = confirm('Are you sure you want to start? Not all players have submitted their clues?')
      }
      console.log('start game', startGame)

      if(startGame) {
        console.log('starting game')
        this.currentGame.set.current_round.completed = true
        this.$store.dispatch('updateGameSet', {gameId: this.currentGame.id, setData: this.currentGame.set}).then(res => {
          console.log('dispatched update', res)
        })
      }
    },
    submitClues: function() {
      var clueArray = this.clues.map(clue => {
        return clue.value.trim()
      })
      clueArray = _.uniq(clueArray)
      var filterClueArray = clueArray.filter(clue => {
        return clue != ""
      })
      console.log(filterClueArray)
      gameAxios.put(this.game.id, {game: {set: {clues: clueArray, players_gone: [this.gameSession.id] }}})
        .then(res => {
          console.log('populate pot')
          // this.currentGame = res.data
        })
    }
  },
  created() {
    for(let i=0; i < this.clueNumbers; i++) {
      this.clues.push({value: ""})
    }
    this.currentGame = this.game
    console.log('host prop', this.currentHost)
    
    
  }
}
</script>

<style scoped>

.clue-input {
  border-color: white !important;
}

.wrap-tile {
   flex-wrap: wrap;
   justify-content: space-between;
}

.card {
  border: 1px solid grey;
  border-radius: 5px;
}

.clue-button {
  margin-top: 100px;
}

.clue-box {
  padding: 0px;
}

</style>

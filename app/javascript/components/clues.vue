<template>
  <div class="tile">
    <div v-if="!cluesSubmitted" class="tile is-parent wrap-tile">
      <div class="tile is-child is-2 box clue-box" v-for="(clue, index) in clues" :key="index">
        <textarea class="textarea clue-input" placeholder="enter a clue" rows="10" v-model="clue.value"></textarea>
      </div>
      <b-button class="clue-button" type="is-dark" @click="submitClues" expanded>Add Clues into the FishBowl</b-button>
    </div>
    <div class="tile is-vertical" v-else>
      <div class="tile is-parent is-vertical">
        <div class="tile is-child">
          <i>Waiting to start the game</i>
        </div>
        <div class="tile is-child">
          <b-button type="is-dark start-button" @click="startGame" v-if="currentHost">Host to Start Game</b-button>
        </div>
      </div>

      <div class="tags are-medium tile is-parent" v-if="submittedPlayers.length > 0">
        <div class="tile is-child box">
          <div class="title is-4">Players submitted clues</div>
          <div :class="['tag', session.host ? 'is-info' : 'is-dark', session.invitation_accepted ? '' : 'is-light']" v-for="session in submittedPlayers" :key="session.id">
            {{session.player_name}}{{ session.host ? ' (host)' : ''}}
          </div>
        </div>

        <div class="tile is-child box">
          <div class="title is-4">Waiting from these Players</div>
          <div :class="['tag', session.host ? 'is-info' : 'is-dark is-light']" v-for="session in notSubmittedPlayers" :key="session.id">
            {{session.player_name}}{{ session.host ? ' (host)' : ''}}
          </div>
        </div>
      </div>

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
      if(_.includes(this.game.set.players_gone, this.gameSession.id)) {
        return true
      } else {
        return false
      }
    },
    submittedPlayers: function() {
      let playerArr = []
      let playersGone = this.game.set.players_gone
      _.forEach(this.game.game_sessions, function(session) {
        if(_.includes(playersGone, session.id)) {
          playerArr.push(session)
        }
      })
      return playerArr
    },
    notSubmittedPlayers: function() {
      let playerArr = []
      let playersGone = this.game.set.players_gone
      _.forEach(this.game.game_sessions, function(session) {
        if(!_.includes(playersGone, session.id)) {
          playerArr.push(session)
        }
      })
      return playerArr
    }
  },
  methods: {
    startGame: function() {
      let startGame = false
      if(this.game.set.players_gone.length != this.game.game_sessions.length) {
        startGame = confirm('Are you sure you want to start? Not all players have submitted their clues?')
      }
      console.log('start game', startGame)

      if(startGame) {
        console.log('starting game')
        let gameSet = this.game.set
        gameSet.current_round.completed = true
        console.log(gameSet)
        this.$store.dispatch('updateGame', {id: this.game.id, set: gameSet}).then(res => {
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
      gameAxios.put(this.game.id.toString(), {game: {set: {clues: clueArray, players_gone: [this.gameSession.id] }}})
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

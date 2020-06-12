<template>
  <component :is="comp" :game="game" :game-session="gameSession" v-on:start-game="goToGameComponent" :game-subscription="gameSubscription" :current-host="currentHost" :turn-start="turnStart" :guessed-clue="guessedClue" :passed="passed"></component>
</template>

<script>
import FishBowl from './fish_bowl';
import WaitingRoom from './waiting_room';
import gameAxios from '../axios/axios_game_update.js';
import { mapGetters } from 'vuex';


export default {
  components: {
    'fish_bowl': FishBowl,
    'waiting_room': WaitingRoom
  },
  props: {
    gameComponent: {
      type: String,
      required: true
    },
    game_id: {
      type: String,
      required: true
    }
  },
  data: function () {
    return {
      comp: null,
      game: null,
      subscription: null,
      turnStart: false,
      guessedClue: null,
      passed: 0
    }
  },
  computed: {
    ...mapGetters({
      gameSession: 'gameSession'
    }),
    currentHost () {
      if(this.$store.getters.gameSession != null || this.$store.getters.gameSession != undefined) {
        return this.$store.getters.gameSession.host
      } else {
        return false
      }
      
    }
  },
  watch: {
    game: function(newVal, oldVal) {
      if(this.gameSession.game_id == newVal.id && newVal.set.current_round.round_number != null) { 
        this.comp = this.$options.filters.camelToUnderscore(newVal.name);
      } else {
        this.comp = 'waiting_room'
      }
    }
  },
  methods: {
    goToGameComponent: function(game) {
      this.game = game
      this.comp = this.$options.filters.camelToUnderscore(game.name)
    }
  },
  created () {
    // this.$store.dispatch('reloadGameSession', {player: {value: this.gameSession.player_name}, gameId: {value: this.game_id}, user: ""})
    if(this.$store.getters.gameSession == null || this.$store.getters.gameSession == undefined) {
      this.$router.push({name: 'join_game', params: { game_id: this.game_id.toString() }})

      return
    }
    gameAxios.get(`${this.game_id}`)
      .then(res => {
        console.log('got game', res)
        // console.log('gameset', res.data.set)
        if(res.data.ended && this.gameSession.game_id != res.data.id) {
          this.$router.push({name: 'join_game'})
        } else {
          this.game = res.data
        }
      })

    // TODO: extract to bus
    const gameId = this.game_id
    this.websocket = this.$cable.useGlobalConnection(this.$store.state.token)
    this.gameSubscription = this.websocket.subscriptions.create({
      channel: 'GamesChannel', game: this.game_id }, {
        connected: () => console.log('Connected to Game Channel', this.game_id),
        received: (data) => {
          console.log('game command received', data)
          if(data.game != null || data.game != undefined) {
            console.log('received game', JSON.parse(data.game))
            this.game = JSON.parse(data.game)
          }
          if(data.turn_start != null || data.turn_start != undefined) {
            this.turnStart = data.turn_start
          }
          if(data.guessed_clue != null || data.guessed_clue != undefined) {
            this.guessedClue = data.guessed_clue
          }

          if(data.passed != null || data.passed != undefined) {
            this.passed = data.passed
          }
        },
        turnStart: function () {
          console.log('starting timer from client', gameId)
          this.perform('turn_start', {game_id: gameId})
        },

        clueGuessed: function(guessedClue) {
          this.perform('guessed_clue', {game_id: gameId, guessed_clue: guessedClue})
        },
        cluesPassed: function(passed) {
          this.perform('passed', {game_id: gameId, passed: passed})
        }
    })
    
  }
}
</script>

<style scoped>

</style>

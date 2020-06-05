<template>
  <div>
    <component :is="comp" :game="game" :game-session="gameSession" v-on:start-game="goToGame" :game-subscription="gameSubscription" :current-host="currentHost" :timer-start="timerStart" :guessed-clue="guessedClue"></component>
  </div>
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
      timerStart: false,
      guessedClue: null
    }
  },
  computed: {
    ...mapGetters({
      gameSession: 'getSession'
    }),
    currentHost () {
      return this.$store.getters.getSession.host
    }
  },
  watch: {
    game: function(newVal, oldVal) {
      if(this.gameSession.game_id == newVal.id && newVal.set.current_round.round_number != null) { 
        this.comp = this.$options.filters.camelToKabab(newVal.name);
      } else {
        this.comp = 'waiting_room'
      }
    }
  },
  methods: {
    goToGame: function(game) {
      this.game = game
      this.comp = this.$options.filters.camelToKabab(game.name)
    }
  },
  created () {
    gameAxios.get(`${this.game_id}`)
      .then(res => {
        console.log('got game', res)
        // console.log('gameset', res.data.set)
        this.game = res.data
      })
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
          if(data.timer_start != null || data.timer_start != undefined) {
            this.timerStart = data.timer_start
          }
          if(data.guessed_clue != null || data.guessed_clue != undefined) {
            this.guessedClue = data.guessed_clue
          }
        },
        timerStart: function () {
          console.log('starting timer from client', gameId)
          this.perform('timer_start', {game_id: gameId})
        },
        clueGuessed: function(guessedClue) {
          this.perform('guessed_clue', {game_id: gameId, guessed_clue: guessedClue})
        }
    })
    
  }
}
</script>

<style scoped>

</style>

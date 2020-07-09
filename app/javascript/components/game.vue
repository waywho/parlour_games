<template>
  <component class="game" :is="comp" :game="game" :game-session="gameSession" v-on:start-game="goToGameComponent" :game-subscription="gameSubscription" :current-host="currentHost"></component>
</template>

<script>
import FishBowl from './fishbowl';
import WaitingRoom from './waiting_room';
import gameAxios from '../axios/axios_game_update.js';
import { mapGetters } from 'vuex';
import { bus } from '../packs/application'
import Ghost from './ghost';
import WinkMurder from './wink_murder'


export default {
  components: {
    'fishbowl': FishBowl,
    'ghost': Ghost,
    'waiting-room': WaitingRoom,
    'wink-murder': WinkMurder
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
      subscription: null
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
      if(this.gameSession.game_id == newVal.id && newVal.started) { 
        this.comp = this.$options.filters.camelToKabab(newVal.name);
      } else {
        this.comp = 'waiting-room'
      }
    }
  },
  methods: {
    goToGameComponent: function(game) {
      this.game = game
      this.comp = this.$options.filters.camelToKabab(game.name)
    }
  },
  created () {
    // this.$store.dispatch('reloadGameSession', {player: {value: this.gameSession.player_name}, gameId: {value: this.game_id}, user: ""})
    if(this.gameSession == null || this.gameSession == undefined) {
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
            // bus.$emit('gameUpdate', JSON.parse(data.game))
          }
          if(data.turn_start != null || data.turn_start != undefined) {
            if(data.turn_start) {
              bus.$emit('startTimer')
            }
          }
          if(data.guessed_clue != null || data.guessed_clue != undefined) {
            bus.$emit('showGuessed', data.guessed_clue)
            // this.guessedClue = data.guessed_clue
          }

          if(data.passed != null || data.passed != undefined) {
            console.log('clues pass', data.passed)
            bus.$emit('cluesPassed', JSON.parse(data.passed))
          }

          if(data.looking != null || data.looking != undefined) {
            console.log("game session", this.gameSession)
            if(data.looking == this.gameSession.id) {
              console.log("looking at me")
              bus.$emit('looking', JSON.parse(data.looker))
            } else {
              bus.$emit('not_looking', JSON.parse(data.looker))
            }
          }
          if(data.killing && data.killer != null || data.killer != undefined) {
            bus.$emit('killing', JSON.parse(data.killer))
          }
        },
        turnStart: function () {
          console.log('starting timer from client', gameId)
          this.perform('turn_start', {game_id: gameId})
        },

        clueGuessed: function(guessedClue) {
          this.perform('guessed_clue', {game_id: gameId, guessed_clue: guessedClue})
        },
        looking: function(lookingId, lookerId) {
          console.log("calling lookings")
          this.perform('looking', {game_id: gameId, looking: lookingId, looker: lookerId})
        },
        killing: function(killer) {
          this.perform('killing', {game_id: gameId, killer: killer})
        }
    })
    
  }
}
</script>

<style scoped>
</style>

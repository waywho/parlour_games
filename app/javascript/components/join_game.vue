<template>
  <div class="">
    <div class="center-content">
      <h5 class="title is-5">Join <span v-if="game.name">{{game.name | camel-to-space}}: {{ formFields.gameId.value }}</span><span v-if="!game.name">Game</span></h5>
      <h6 class="subtitle is-6" v-if="host_names">hosted by: {{ host_names }}</h6>

      <b-field v-show="!game_id" label="Enter Game ID" :type="formFields.gameId.classType" :message="formFields.gameId.message">
        <b-input placeholder="Game ID" v-model="formFields.gameId.value" :type="formFields.gameId.type" @blur="getGame(formFields.gameId.value)"></b-input>
      </b-field>
      <b-field label="Enter your name..."  :type="formFields.player.classType" :message="formFields.player.message">
        <b-input placeholder="Player name" v-model="formFields.player.value" :type="formFields.player.type"></b-input>

      </b-field>
      <p class="control">
        <b-button class="button is-dark" @click="joinGame">Join Game</b-button>
<!--         <b-button class="button is-default" @click="joinGameAsIs">Join Game As User</b-button> -->
        <b-button class="button is-default" @click="rejoinGame">Re-Join Game</b-button>
      </p>
      
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import gameAxios from '../axios/axios_game_update.js';
import FormErrorHandlingMixin from '../mixins/FormErrorHandlingMixin';
import { mapGetters } from 'vuex';

export default {
  props: {
    game_id: {
      type: String,
      required: false
    }
  },
  mixins: [FormErrorHandlingMixin],
  data: function () {
    return {
      gameSession: null,
      formFields: {
        gameId: { value: null, type: 'number', message: null, classType: null},
        player: { value: null, type: 'string', message: null, classType: null}
      },
      game: {
        id: null, 
        set: {
          turn:{ 
            current_team: null, 
            nominated_player: null
          }, 
          clues:[], 
          rounds:{}, 
          current_round:{
            teams:{}, 
            round_number:null
          }, 
          guessed_clues:[]
        }, 
        hosts: [],
      }
    }
  },
  computed: {
    ...mapGetters({
      gameSession: 'getSession',
      currentUser: 'currentUser'
    }),
    host_names: function() {
      return _.map(this.game.hosts, "name").join(", ")
    }
  },
  methods: {
    joinGame: function() {
      console.log('game id', this.formFields.gameId.value)
      if(this.requiredFieldsErrors(['gameId', 'player'])) {
        return
      }
      axios.post('/api/game_sessions', {game_session: { player_name: this.formFields.player.value, game_id: this.formFields.gameId.value, invitation_accepted: true }})
        .then(res => {
          console.log('join game', res.data)
          localStorage.setItem('game_session', JSON.stringify(res.data))
          this.$store.dispatch('resetGameSession')
          this.$router.push({name: 'game', params: { gameComponent: this.game.name, game_id: this.formFields.gameId.value.toString() }})
        })
    },
    rejoinGame: function() {
      let user = null
      if(this.$store.getters.authenticated) {
        user = `&playerable_id=${this.currentUser.id}&playerable_type=User`
      }

      this.$store.dispatch('reloadGameSession', {player: {value: this.gameSession.player_name}, gameId: {value: this.game.id}, user: user}).then(res => {
        this.$router.push({name: 'game', params: { gameComponent: this.game.name, game_id: this.formFields.gameId.value.toString() }})
      })
    },
    joinGameAsIs: function() {
      // if(this.requiredFieldsErrors(['player'])) {
      //   return
      // }

      this.$router.push({name: 'game', params: { gameComponent: this.game.name, game_id: this.formFields.gameId.value.toString() }})
    },
    checkPlayerStatus: function() {
    },
    getGame: function(id) {
      gameAxios.get(`${id}`)
      .then(res => {
        console.log('get game', res)
        this.game = res.data
      })
    }
  },
  created() {
    if(this.game_id !== null && this.game_id !== undefined) {
      this.formFields.gameId.value = this.game_id
      this.getGame(this.game_id)
      
    }
    
  }
}
</script>

<style scoped>

.center-content {
  margin: auto;
  width: 500px;
}

</style>

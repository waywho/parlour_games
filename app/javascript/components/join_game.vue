<template>
  <div class="center-content">
    <h5 class="title is-5">Join <span v-if="game.name">{{game.name | camel-to-space}}: {{ formFields.gameId.value }}</span><span v-if="!game.name">Game</span></h5>
    <h6 class="subtitle is-6" v-if="host_names">hosted by: {{ host_names }}</h6>
    <p v-if="game.description">{{game.description}}</p>
    <br />
    <b-message type="is-dark" :active.sync="showError">
          {{errorMessage}}
    </b-message>
    <b-field v-show="!game_id || game_ended" label="Enter Game ID" :type="formFields.gameId.classType" :message="formFields.gameId.message">
      <b-input placeholder="Game ID" v-model="formFields.gameId.value" :type="formFields.gameId.type" @blur="getGame(formFields.gameId.value)"></b-input>
    </b-field>
    <b-field label="Enter a name..."  :type="formFields.player.classType" :message="formFields.player.message" @input="checkPlayerName" @blur="checkPlayerName">
      <b-input placeholder="Player name" v-model="formFields.player.value" :type="formFields.player.type" @input="checkPlayerName"></b-input>

    </b-field>
    <p class="control">
      <b-button class="button is-dark" @click="joinGame" v-if="!rejoin" :disabled="disableJoin">Join Game</b-button>
<!--         <b-button class="button is-default" @click="joinGameAsIs">Join Game As User</b-button> -->
      <b-button class="button is-dark" @click="rejoinGame" v-if="rejoin" :disabled="disableJoin">Re-Join Game</b-button>
    </p>
    
  </div>
</template>

<script>
import axios from 'axios';
import gameAxios from '../axios/axios_game_update.js';
import FormErrorHandlingMixin from '../mixins/FormErrorHandlingMixin';
import goToGame from '../mixins/goToGame';
import { mapGetters } from 'vuex';

export default {
  props: {
    game_id: {
      type: String,
      required: false
    }
  },
  mixins: [FormErrorHandlingMixin, goToGame],
  data: function () {
    return {
      errorMessage: null,
      showError: false,
      rejoin: false,
      disableJoin: false,
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
      gameSession: 'gameSession',
      currentUser: 'currentUser'
    }),
    host_names: function() {
      return _.map(this.game.hosts, "name").join(", ")
    },
    game_ended: function() {
      return this.game.ended
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
          this.$store.dispatch('resetGameSession', res.data)
          this.goGame()
        })
    },
    rejoinGame: function() {
      let user = ""
      if(this.$store.getters.authenticated) {
        user = `&playerable_id=${this.currentUser.id}&playerable_type=User`
      }
      // console.log('fomr data', {player: {value: this.formFields.player.value}, gameId: {value: this.formFields.gameId.value}, user: user})
      this.$store.dispatch('reloadGameSession', {player: {value: this.formFields.player.value}, gameId: {value: this.formFields.gameId.value}, user: user}).then(res => {
        this.goGame()
      })
    },
    // not yet in use
    checkPlayerName: function() {
      this.errorMessage = null
      this.showError = false
      this.rejoin = false
      gameAxios.get(`${this.formFields.gameId.value}`)
        .then(res => {
          let playerNames = _.map(res.data.game_sessions, 'player_name')
          if(_.includes(playerNames, this.formFields.player.value)) {
            this.disabledJoin = true
            
            // TODO: if player appeared online joined already
            this.formFields.player.message = "sorry, name already taken."
            this.formFields.player.classType = 'is-danger'
            this.rejoin = true

            // TODO: if player has not appeared
            this.errorMessage = "Are you trying to re-join the game?"
            this.showError = true
            
          } else {
            this.errorMessage = null
            this.showError = false
          }
        })

    },
    joinGameAsIs: function() {
      this.goGame()
    },
    goGame: function() {
      // method from mixing
      this.goToGame(this.game.name, this.formFields.gameId.value);
    },
    getGame: function(id) {
      this.showError = false
      this.errorMessage = null
      this.rejoin = false
      
      if(this.formFields.player.value != null || this.formFields.player.value != undefined ) { this.formFields.player.value = null}

        gameAxios.get(`${id}`)
          .then(res => {
            console.log('get game', res)
            this.game = res.data
            this.formFields.gameId.value = this.game.id
            if(this.game_ended) {
              this.errorMessage = "This game has finished, please enter another game code"
              this.showError = true
            } else if(this.gameSession != null || this.gameSession != undefined) {
              if(this.gameSession.game_id == this.game.id) {
                this.formFields.player.value = this.gameSession.player_name
                this.rejoin = true
                this.errorMessage = "Looks like you were part of this game already, would you like to join again?"
                this.showError = true
              }
            }
          })
      
    }
  },
  mounted() {
    // already a signed in user, or has a game session
    if(this.game_id !== null && this.game_id !== undefined) {
      this.formFields.gameId.value = this.game_id
      this.getGame(this.game_id)
    } else if (this.gameSession != null || this.gameSession != undefined) {
      this.getGame(this.gameSession.game_id)
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

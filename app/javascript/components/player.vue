<template>
  <b-tag v-on:dblclick.native="playerOptions"  :class="[gameSession.host ? 'is-info' : 'is-dark', gameSession.invitation_accepted ? '' : 'is-light', pointerType]" >
    <b-tooltip v-if="optionable" label="Double click for options" type="is-dark" size="is-small" :delay="1000" postion="is-top">
      {{gameSession.player_name}}{{ gameSession.host ? ' (host)' : ''}}
    </b-tooltip>
    <span v-else>
      {{gameSession.player_name}}{{ gameSession.host ? ' (host)' : ''}}
    </span>
    <b-modal :active.sync="isModalActive" 
                 has-modal-card
                 trap-focus
                 aria-role="dialog"
                 aria-modal
                 @close="errorMessage = null">

      <div class="modal-card" style="width: auto">
          <header class="modal-card-head">
              <p class="modal-card-title">Player Options: {{gameSession.player_name}}</p>
          </header>
          <section class="modal-card-body">
            <b-message v-if="errorMessage" type="is-danger" size="is-small">
              {{errorMessage}}
            </b-message>
              <b-field label="Change name">
                  <b-input
                      type="string"
                      v-model="playerName"
                      placeholder="enter a different name"
                      >
                  </b-input>
                  <p class="control">
                    <button @click="changeName" class="button is-dark" :disabled="changeButtonDisable">Change</button>
                  </p>
              </b-field>
              <div class="divider">{{leaveGameHint}}</div>
              <div class="buttons">
                <b-button type="is-danger" @click="leaveGame" expanded>Leave Game</b-button>
              </div>
          </section>
      </div>

    </b-modal>
  </b-tag>
</template>

<script>
import { mapGetters } from 'vuex';
import axios from 'axios';
import Qs from 'qs';

export default {
  props: {
    'gameSession': {
      type: Object,
      required: true
    },
    'currentHost': {
      type: Boolean,
      required: true
    },
    'dragger': {
      type: Boolean,
      required: false,
      default: false
    }
  },
  data: function () {
    return {
      isModalActive: false,
      playerName: this.gameSession.player_name,
      errorMessage: null,
      changeButtonDisable: true
    }
  },
  computed: {
    ...mapGetters({
      myGameSession: 'gameSession'
    }),
    pointerType: function() {
      return this.dragger ? 'player' : 'pointed'
    },
    optionable: function() {
      if(this.myGameSession == null || this.myGameSession == undefined) {
        return false
      } else {
        return this.currentHost || this.gameSession.id == this.myGameSession.id
      }
      
    },
    leaveGameHint: function() {
      if(this.myGameSession != null || this.myGameSession != undefined) {
        if(this.gameSession.id == this.myGameSession.id) {
          return "leave game"
        } else if (this.currentHost) {
          return `force ${this.gameSession.player_name} to leave game`
        }
      }
    }
  },
  watch: {
    playerName(newVal, oldVal) {
      this.changeButtonDisable = false
    }
  },
  methods: {
    leaveGame: function() {
      let leaveGame = confirm(`Are you sure you want to ${this.leaveGameHint}? This cannot be undone`)
      console.log('leave game', leaveGame)
      if(leaveGame) {
        axios.delete(`/api/game_sessions/${this.gameSession.id}`)
        .then(res => {
          console.log('leave game', res.data)
          this.$store.dispatch('clearGameSession')
          this.$router.push({name: 'join_game_noid'})
        })
      }
      
    },
    playerOptions: function() {
      if(this.optionable) {
        this.isModalActive = true
      }
    },
    changeName: function() {
      axios({
        method: 'patch',
        url: `/api/game_sessions/${this.gameSession.id}`, 
        params: {game_session: {player_name: this.playerName}},
        paramsSerializer: function(params) {
          return Qs.stringify(params, {arrayFormat: 'brackets'})
        }
      }).then(res => {
          this.isModalActive = false
      }).catch(error => {
        this.errorMessage = "oops, something went wrong!"
      })
    }
  }
}
</script>

<style scoped lang="scss">
.pointed {
  cursor: default;
  cursor: -moz-default;
  cursor: -webkit-default;
}

.player {
  cursor: grab;
  cursor: -moz-grab;
  cursor: -webkit-grab;
}

.player:active {
  cursor: grabbing;
  cursor: -moz-grabbing;
  cursor: -webkit-grabbing;
}

.delete {
  /*display: none !important;*/
  visibility: hidden !important;
}
.player:hover > .delete {
  visibility: visible !important;
  /*display: inline-block !important;*/
}
</style>

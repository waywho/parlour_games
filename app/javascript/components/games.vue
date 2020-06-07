<template>
  <div>
    <h2 class="title is-2">Games</h2>
    <b-button v-for="game in games" type="is-dark" @click="startGameInvite(game)" expanded outlined>
      Start {{game | camel-to-space }}
    </b-button>
     <b-modal :active.sync="isComponentModalActive" 
                 has-modal-card
                 trap-focus
                 aria-role="dialog"
                 aria-modal>
      <component :is="currentForm" :game_name="currentGameName" :game_id="currentGameId" v-on:send-invite="sendGameInvite" v-on:no-invite="noInvite"></component>
    </b-modal>
  </div>
</template>

<script>
import parlourAxios from '../axios/axios_parlour.js';
import GameInvite from './game_invite_form';
import { mapGetters } from 'vuex'
import goToGame from '../mixins/goToGame';

export default {
  components: {
    'game-invite': GameInvite
  },
  data: function () {
    return {
      isComponentModalActive: false,
      currentForm: 'game-invite',
      users: null,
      currentGameName: null,
      currentGameId: null,
      games: ['FishBowl']
    }
  },
  mixins: [goToGame],
  computed: {
    ...mapGetters({
      currentUser: 'currentUser'
    })
  },
  methods: {
    startGameInvite: function(game_name) {
     parlourAxios.post('/games', {game: {name: game_name} })
      .then(res => {
        const host = res.data.hosts.filter(host => {
          return host.playerable_id == this.$store.getters.currentUser.id
        })[0]

        this.$store.dispatch('resetGameSession', host)

        this.currentGameId = res.data.id 
        this.currentGameName = this.$options.filters.camelToUnderscore(res.data.name)
        this.isComponentModalActive = true
      })   
    },
    noInvite: function() {
      this.isComponentModalActive = false
      this.goToGame(this.currentGameName, this.currentGameId)
    },
    sendGameInvite: function(userIds) {
      console.log('game invite user ids', userIds)
      parlourAxios.post('/game_sessions', {user_ids: userIds, game_session: { game_id: this.currentGameId }})
        .then(res => {
        this.isComponentModalActive = false
        this.goToGame(this.currentGameName, this.currentGameId)
      })
    }
  },
  created() {

  }

}
</script>

<style scoped>

</style>

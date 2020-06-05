<template>
  <div>
    <b-button v-for="game in games" type="is-dark" @click="startGameInvite(game)" expanded outlined>
      Start {{game | camel-to-space }}
    </b-button>
     <b-modal :active.sync="isComponentModalActive" 
                 has-modal-card
                 trap-focus
                 aria-role="dialog"
                 aria-modal>
      <component :is="currentForm" :game_name="currentGameName" :game_id="currentGameId" v-on:send-invite="sendGameInvite" v-on:no-invite="sendGameInvite"></component>
    </b-modal>
  </div>
</template>

<script>
import parlourAxios from '../axios/axios_parlour.js';
import GameInvite from './game_invite_form';
import { mapGetters } from 'vuex'

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
        localStorage.setItem('game_session', JSON.stringify(host))
        this.currentGameId = res.data.id 
        this.currentGameName = game_name
        this.isComponentModalActive = true
      })   
    },
    sendGameInvite: function(userIds) {
      console.log('game invite user ids', userIds)
      // axios.post('/games', {game: game})
      parlourAxios.post('/game_sessions', {user_ids: userIds, game_session: { game_id: this.currentGameId }})
        .then(res => {
        this.isComponentModalActive = false
        const comp = this.$options.filters.camelToKabab(res.data.name)
        console.log(comp)
        this.$router.push({name: 'join_game', params: {game_id: this.currentGameId.toString() }})
      })
    }
  },
  created() {

  }

}
</script>

<style scoped>

</style>

<template>
  <div>
    <h2 class="title is-2">Games</h2>
    <div class="columns">
      <div class="column" v-for="game in games">
        <button  class="button game-button is-outlined is-dark" @click="startGameInvite(game)" outlined>
        <img :src="fishBowlImage" alt="Fish Bowl" class="game-image">
        Start {{game | camel-to-space }}
      </button>
      </div>
    </div>
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
import fishBowlImage from '../assets/fish-bowl-filled-glow.png'

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
      games: ['FishBowl'],
      fishBowlImage: fishBowlImage
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
.game-button {
  height: 250px;
  width: 250px;
  display: flex;
  flex-direction: column;
}

</style>

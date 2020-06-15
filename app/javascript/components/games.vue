<template>
  <div>
    <h2 class="title is-2">Games</h2>
    <div class="columns">
      <div class="column center-tile vertical-tile" v-for="game in games">
        <button  class="button game-button is-outlined is-dark" @click="startGameInvite(game.name)" outlined>
        <img :src="fishBowlImage" alt="Fishbowl" class="game-image">
        Start {{game.name | camel-to-space }}
      </button>
       <b-tooltip :label="game.description" type="is-light"
          position="is-bottom" multilined size="is-medium">
          <div class="tag is-light is-small">
              more about the game
          </div>
        </b-tooltip>
      </div>
    </div>
    <b-modal :active.sync="isComponentModalActive" 
                 has-modal-card
                 trap-focus
                 aria-role="dialog"
                 aria-modal>
      <component :is="currentForm" :game-name="newGameName" :game-id="newGameId" v-on:send-invite="sendGameInvite" v-on:no-invite="noInvite"></component>
    </b-modal>
  </div>
</template>

<script>
import parlourAxios from '../axios/axios_parlour.js';
import GameInvite from './game_invite_form';
import { mapGetters } from 'vuex'
import goToGame from '../mixins/goToGame';
import fishBowlImage from '../assets/fish-bowl-glow.png'

export default {
  components: {
    'game-invite': GameInvite
  },
  data: function () {
    return {
      isComponentModalActive: false,
      currentForm: 'game-invite',
      users: null,
      newGameName: null,
      newGameId: null,
      games: [{name: 'Fishbowl', description: "This is a great group game. Teams will guess the same clues through rounds of giving descriptions (Taboo), acting out (Charades), and single describing word (Password). "}],
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
    startGameInvite: function(gameName) {
     parlourAxios.post('/games', {game: {name: gameName} })
      .then(res => {
        const host = res.data.hosts.filter(host => {
          return host.playerable_id == this.$store.getters.currentUser.id
        })[0]

        this.$store.dispatch('resetGameSession', host)

        this.newGameId = res.data.id 
        this.newGameName = this.$options.filters.camelToUnderscore(res.data.name)
        this.isComponentModalActive = true
      })   
    },
    noInvite: function() {
      this.isComponentModalActive = false
      this.goToGame(this.newGameName, this.newGameId)
    },
    sendGameInvite: function(userIds) {
      console.log('game invite user ids', userIds)
      parlourAxios.post('/game_sessions', {user_ids: userIds, game_session: { game_id: this.newGameId }})
        .then(res => {
        this.isComponentModalActive = false
        this.goToGame(this.newGameName, this.newGameId)
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

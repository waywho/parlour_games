<template>
  <b-modal :active.sync="isModalActive" 
                 has-modal-card
                 aria-role="dialog"
                 aria-modal
                 :can-cancel="false"
                 >
    <div class="modal-content">
    <!-- Any other Bulma elements you want -->
      <img :src="gameImage" alt="Fish Bowl" class="game-image">
      <div class="box round-label">
        
        <div class="title is-verticle">{{currentRound.phase}}</div>
        <b-message v-if="showMessage" type="is-danger" has-icon>
            {{showMessage}}
        </b-message>

        <b>{{challengeInstructions[stage]}}</b>
        
        <div v-if="currentRound.phase == 'accusation'"class="tile center-tile pt-1 is-vertical">
        
        <b-field v-if="currentAccuser && !accusationMade">
          <b-radio-button v-for="(player, index) in game.game_sessions" :native-value="player.id" type="is-dark" size="is-medium" outlined :key="index" v-model="accused">{{player.player_name}}
            </b-radio-button>
        </b-field>
        </div>
        <div v-if="!refusedSeconder" class="control has-text-centered pt-2">
          <!-- -->
          <b-button v-if="stage == 'seconder-seeking'" type="is-dark" @click="seconder">{{seconderButton}}</b-button>
          <b-button v-if="stage == 'seconder-seeking'" type="is-dark" @click="noSeconder">Nope</b-button>
          <b-button v-if="stage =='accusation'" type="is-dark" @click="challenge">Accuse</b-button>
        </div>
      </div>
    </div>
  </b-modal>
</template>

<script>
import scoreBoard from './score_board';
import { mapGetters } from 'vuex';
export default {
  props: {
    currentRound: {
      type: Object,
      required: true
    },
    showScores: {
      type: Boolean,
      required: false,
      default: false
    },
    scoringParties: {
      type: Array,
      required: false
    },
    game: {
      type: Object,
      required: true
    },
    cancelOutside: {
      type: Boolean,
      required: false,
      default: true
    },
    gameSession: {
      type: Object,
      required: false
    }
  },
  components: {
    'score-board': scoreBoard,
  },
  data: function () {
    return {
      isModalActive: false,
      accused: null,
      doubleChecked: false,
      confirmation: false,
      challengeInstructions: {
        "seconder-seeking": "Do you know who the Wink Murderer is?",
        "accusation": "Pick the Wink Murderer:",
        "first-accuser": "Waiting for a Seconder to come forward.",
        "refused-seconder": "Waiting to see what others say.",
        "seconder-found": "Seconder found, waiting for the challenge.",
        "accusation-made": "Waiting for the other challenge"
      }
    }
  },
  computed: {
    ...mapGetters({
      gameInfo: 'gameInfo'
    }),
    stage: function() {
      if (this.refusedSeconder && this.currentRound.phase == "seconder-seeking") {
        return "refused-seconder" 
      } else if(this.currentRound.phase == "seconder-seeking" && this.accuserOrder != 'first') {
        return 'seconder-seeking'
      } else if (this.currentRound.phase == "seconder-seeking" && this.accuserOrder == 'first') {
        return 'first-accuser'
      } else if (this.currentRound.phase == 'accusation' && !this.currentAccuser) {
        return 'seconder-found'
      } else if (this.currentRound.phase == 'accusation' && this.currentAccuser && !this.accusationMade) {
        return "accusation"
      } else if (this.currentRound.phase == 'accusation' && this.currentAccuser && this.accusationMade ) {
        return "accusation-made"
      }
    },
    refusedSeconder: function() {
      return _.includes(this.game.turn_order.accusations.no_seconders, this.gameSession.id)
    },
    gameImage: function() {
      return this.$store.getters.gameInfo(this.game.name).glow
    },
    accusers: function() {
      return _.map(this.game.turn_order.accusations, 
        function(o) { 
          if(o != undefined && o != null && _.includes(Object.keys(o), "accuser")) {
            return o.accuser 
          }
        })
    },
    currentAccuser: function() {
      return _.includes(this.accusers, this.gameSession.id)
    },
    accusationMade: function() {
      if(this.accuserOrder != undefined || this.accuserOrder != null) {
        return this.game.turn_order.accusations[this.accuserOrder].accused != null || this.game.turn_order.accusations[this.accuserOrder].accused != undefined
      } else {
        return false
      }
      
    },
    accuserOrder: function() {
      if(this.game.turn_order.accusations.first.accuser == this.gameSession.id) {
        return 'first'
      } else if (this.game.turn_order.accusations.second != undefined && this.game.turn_order.accusations.second.accuser == this.gameSession.id) {
        return 'second'
      } else {
        return null
      }
    },
    otherAccuserOrder: function() {
      if(this.game.turn_order.accusations.first.accuser == this.gameSession.id) {
        return 'second'
      } else if (this.game.turn_order.accusations.second.accuser == this.gameSession.id) {
        return 'first'
      }
    },
    seconderButton: function() {
      if(this.doubleChecked) {
        return "Sure"
      } else {
        return "I Second"
      }
    },
    showMessage() {
      if(this.accused != null) {
        return "Are you sure? If you are wrong, you will be out of the game."
      } else if (this.confirmation) {
        return "Are you sure? As a seconder, you will also be out of the game if the guesses are wrong. If you are sure, click sure."
      } else {
        return false
      }
    }
  },
  watch: {
    
  },
  methods: {
    close: function() {
      this.isModalActive = false
    },
    activate: function() {
      this.isModalActive = true
    },
    seconder: function() {
      if(this.doubleChecked == false) {
        this.confirmation = true
      } else {
        this.confirmation = false
        this.$emit('update-phase', 'second')
      }
      
      this.doubleChecked = !this.doubleChecked
    },
    noSeconder: function() {
      var accusations = this.game.turn_order.accusations
      accusations.do_not_second = this.gameSession.id
      this.$store.dispatch('updateGame', {
        id: this.game.id,
        accusations: accusations
      }).then(res => {
        // console.log('dispatched update received', res)
      })
    },
    challenge: function() {
      var round = this.game.set.current_round
      var accusations = this.game.turn_order.accusations
      
      accusations[this.accuserOrder].accused = this.accused
      
      this.$store.dispatch('updateGame', {
        id: this.game.id,
        accusations: accusations
      }).then(res => {
        this.accused = null
        // console.log('dispatched update received', res)
      })
    }
  },
  created () {
    
  }
}
</script>

<style scoped lang="scss">
.modal-content {
  overflow: visible;
  width: 90%;
  margin: auto;
}

.round-label {
  text-align: center;
  position: relative;
}

.game-image {
  position: absolute;
  top: -80px;
  left: 50%;
  transform: translateX(-50%);
  height: 100px;
  width: 100px;
  z-index: 20;
}


</style>

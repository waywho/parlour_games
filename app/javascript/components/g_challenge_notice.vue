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
      showMessage: "",
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
    gameImage: function() {
      return this.$store.getters.gameInfo(this.game.name).glow
    },
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

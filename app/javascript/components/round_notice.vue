<template>
  <b-modal :active.sync="isModalActive" 
                 has-modal-card
                 aria-role="dialog"
                 aria-modal
                 :can-cancel="cancelPlaces"
                 >
    <div class="modal-content">
    <!-- Any other Bulma elements you want -->
      <img :src="gameImage" alt="Fish Bowl" class="game-image">
      <div class="box round-label">
        
        <div class="title is-4">{{currentRound.name}}</div>
        <div v-if="showScores">
          <p>{{currentRound.instructions}}</p>
          <score-board :teams="scoringParties" :rounds="game.set.rounds_played" class="is-fullwidth"></score-board>
        </div>
        <div v-else>
          <p v-if="instructionArray" v-html="currentRound.instructions.join('<br/>')"></p>
          <p v-else>{{currentRound.instructions}}</p>
        </div>
        <div v-if="enableNextRound" class="control has-text-centered pt-6">
            <b-button type="is-dark" @click="nextRound">Next Round</b-button>
            <b-button type="is-dark" @click="endGame">End Game</b-button>
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
    enableNextRound: {
      type: Boolean,
      required: false,
      default: false
    },
    game: {
      type: Object,
      required: true
    },
    cancelOutside: {
      type: Boolean,
      required: false,
      default: true
    }
  },
  components: {
    'score-board': scoreBoard,
  },
  data: function () {
    return {
      isModalActive: false
    }
  },
  computed: {
    ...mapGetters({
      gameInfo: 'gameInfo'
    }),
    gameImage: function() {
      return this.$store.getters.gameInfo(this.game.name).glow
    },
    instructionArray: function() {
      // console.log('inst', this.currentRound.instructions)
      // console.log("array", typeof(this.currentRound.instructions))
      return typeof(this.currentRound.instructions) == 'object'
    },
    cancelPlaces: function() {
      if(this.cancelOutside) {
        return ['outside']
      }
    }
  },
  watch: {
    currentRound: function(newVal, oldVal) {
      if(newVal.name != oldVal.name || oldVal == undefined || oldVal == null) {
        this.isModalActive = true
      }
    },
    // isModalActive: function(newVal, oldVal) {
    //   if(newVal) {
    //     setTimeout(() => {this.isModalActive = false}, 3000)
    //   }
    // }
  },
  methods: {
    close: function() {
      this.isModalActive = false
    },
    activate: function() {
      this.isModalActive = true
    },
    nextRound: function() {
      let roundData = this.game.set.current_round
     roundData.round_number += 1
      this.$store.dispatch('updateGame', {
          id: this.game.id,
        }).then(res => {
          // console.log('dispatched update received', res)
          this.isModalActive = false
        })
    },
    endGame: function() {
      this.$store.dispatch('updateGame', {
          id: this.game.id,
          ended: true
        }).then(res => {
          // console.log('dispatched update received', res

          this.isModalActive = false
        })
    }
  },
  created () {
    if(this.currentRound.name == 'Clues') {
      this.isModalActive = true
    }
    
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

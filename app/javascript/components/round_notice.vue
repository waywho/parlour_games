<template>
  <b-modal :active.sync="isModalActive" 
                 has-modal-card
                 aria-role="dialog"
                 aria-modal
                 can-cancel
                 >
    <div class="modal-content">
    <!-- Any other Bulma elements you want -->
      <img :src="gameImage" alt="Fish Bowl" class="game-image">
      <div class="box round-label">
        
        <div class="title is-4">{{currentRound.name}} Round</div>
        <p>{{currentRound.instructions}}</p>
      </div>
    </div>
  </b-modal>
</template>

<script>
import fishBowlImage from '../assets/fish-bowl-filled-glow.png'
export default {
  props: ['currentRound'],
  data: function () {
    return {
      isModalActive: false,
      gameImage: fishBowlImage
    }
  },
  watch: {
    currentRound: function(newVal, oldVal) {
      if(newVal.name != oldVal.name || oldVal == undefined || oldVal == null) {
        this.isModalActive = true
      }
    },
    isModalActive: function(newVal, oldVal) {
      if(newVal) {
        setTimeout(() => {this.isModalActive = false}, 1800)
      }
    }
  },
  methods: {
    
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

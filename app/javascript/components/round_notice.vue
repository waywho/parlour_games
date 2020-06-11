<template>
  <b-modal :active.sync="newRound" 
                 has-modal-card
                 aria-role="dialog"
                 aria-modal
                 >
    <div class="modal-content">
    <!-- Any other Bulma elements you want -->
      <img :src="gameImage" alt="Fish Bowl" class="game-image">
      <div class="box round-label">
        
        <div class="title is-4">{{gameRound.name}} Round</div>
        <p>{{gameRound.instructions}}</p>
      </div>
    </div>
  </b-modal>
</template>

<script>
import fishBowlImage from '../assets/fish-bowl-filled-glow.png'
export default {
  props: ['gameRound', 'newRound'],
  data: function () {
    return {
      isModalActive: false,
      gameImage: fishBowlImage
    }
  },
  watch: {
    currentRound: function(newVal, oldVal) {
   
        this.isModalActive = true
      
    }
  },
  methods: {
    
  },
  created () {
    
    
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

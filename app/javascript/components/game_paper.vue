<template>
  <div class="game-paper">
     <textarea class="clue-input clue-box" placeholder="enter a clue" rows="6" v-model="currentClue"></textarea>
    <div v-for="b in 4" class="folded-part">
     
    </div>
    
  </div>
</template>

<script>

export default {
  props: ['clue'],
  data: function () {
    return {
    }
  },
  computed: {
    currentClue: {
      get() {
        return this.clue
      },
      set(clue) {
        this.$emit('input', clue)
      }
    }
  },
  methods: {
    
  },
  created () {
    
    
  }
}
</script>

<style scoped lang="scss">
@import '~bulma';
$clr1: #F8F3E8;

textarea {
  text-align: center;
  border: 0px none transparent;
  background: transparent;
  border-radius: 15px;
  font-size: 20px;
  font-weight: bold;
  resize: none;
  outline: none !important;
  color: #363636;
  display: block;
  position: absolute;
  top: 0;
  z-index: 99;
  width: 100%;
  height: 100%;
  padding-top: 25%;
}

.game-paper {
  height: 350px;
  width: 350px;
  perspective: 800px;
  border: 1px solid $grey-light;
  // box-shadow: 0px 0px 40px $grey-lightest;
  position: absolute;
  top: 0;
  z-index: -1;
  display: none;
}

.folded-part {
  position: absolute;
  width: 50%;
  height: 50%;
  background: darken($white-ter, 2%);
  box-shadow: 0 0 40px rgba(0,0,0,0.08);

  &:nth-child(1) {
    background: darken($white-ter, 2.5%);
    left: 0;
    top: 0;
  }
  &:nth-child(2) {
    right: 0;
    top: 0;
  }
  &:nth-child(3) {
    left: 0;
    bottom: 0;
  }
  &:nth-child(4) {
    right: 0;
    bottom: 0;
  }
}

@for $i from 1 through 3 {

  .game-paper:nth-child(#{$i}) {
    height: 98%;
    position: absolute;
    background: $white;
    
    @if $i == 1 {
      
      display: block;
    }

    @if $i == 2 {
      left: -4px;
      top: 4px;
      transform: rotate(-2.5deg);
      box-shadow: 0 0 8px rgba(0,0,0,0.2);
      display: block;
    }

    @if $i == 3 {
      left: 4px;
      top: 2px;
      box-shadow: 0 0 3px rgba(0,0,0,0.2);
      transform: rotate(2deg);
      display: block;
      z-index: 0;
    }
  }
  
}



</style>

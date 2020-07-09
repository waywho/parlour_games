<template>
  <div class="game-card">
    <textarea v-if="useTextarea" class="clue-input clue-box" placeholder="enter a clue" rows="6" v-model="clue"></textarea>
    <span v-else>{{term}}</span>
  </div>
</template>

<script>

export default {
  props: {
    useTextarea: {
      type: Boolean,
      required: false,
      default: true
    },
    term: {
      type: String,
      required: false
    }
  },
  data: function () {
    return {
      clue: "" 
    }
  },
  methods: {
    
  },
  created () {
    
    
  }
}
</script>

<style scoped lang="scss">
textarea {
  text-align: center;
  border: 0px none transparent;
  border-radius: 15px;
  font-size: 20px;
  font-weight: bold;
  resize: none;
  outline: none !important;
  color: #363636;
  display: block;
}

.game-card {
  border-radius: 15px;
  position: absolute;
  top: 0;
  width: 280px;
  height: 80vw;
  display: flex !important;
  align-items: center;
  justify-content: center;

  &::after {
    width: 21px;
    height: 3px;
    position: absolute;
    right: 0;
    bottom: 11px;
    left: 0;
    margin: auto;
    border-radius: 100px;
    background: (0, 0,0, 0.3);
  }
  background-color: white;
  z-index: 2;
  max-height: 350px;
  font-size: 28px;
  font-weight: bold;
  color: black;
  border: 1px solid black;
  transform-origin: 50% 100%;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
}

.game-card:nth-child(2) {
  z-index: 1;
  transform: translateY(55vh * 0.018 *2) scale(1-(0.04 *2)) ;
}

.game-card:nth-child(3) {
  z-index: 0;
  transform: translateY(55vh * 0.024 *3) scale(1-(0.06 *3)) ;
}
</style>

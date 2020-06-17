<template>
  <div class="columns">
    <div class="column">
      <div class="columns is-multiline">
        <div class="column is-full letter-arena">
          <div class="tags are-light are-xlarge">
            <span class="tag" v-for="letter in playWord">{{letter}}</span>
          </div>
        </div>
        <div class="column is-full">
          <div class="buttons">
            <b-button type="is-dark" v-for="(l, index) in letters" @click="playLetter(l)" :value="l" :key="index">{{l}}</b-button>
          </div>
        </div>
      </div>
    </div>
    <div class="column">
      
    </div>
  </div>
</template>

<script>

export default {
  props: ['game'],
  data: function () {
    return {
      currentGame: null,
      playWord: null,
      letters: ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    }
  },
  computed: {
   
  },
  methods: {
    playLetter: function(e) {
      console.log("letter", e)
      this.playWord.push(e)
    }
  },
  created () {
    this.currentGame = this.game
    this.playWord = this.currentGame.set.play_word
    
  }
}
</script>

<style scoped lang="scss">
.letter-arena {
  min-height: 350px;
}

.tags.are-xlarge > .tag {
  font-size: 3em;
}
</style>

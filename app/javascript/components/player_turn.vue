<template>
  <b-taglist attached class="no-margin">
    <b-tag v-if="passing" type="is-light" size="is-medium" class='light-tag'>{{game.set.current_turn.passed}}</b-tag>
    <b-tag type="is-dark" size="is-medium">{{currentPlayerName}}</b-tag>
    <b-tag type="is-light" size="is-medium" class='light-tag'>{{currentPlayerScore}}</b-tag>
  </b-taglist>  
</template>

<script>

export default {
  props: {
    passing:  {
      type: Boolean,
      required: false,
      default: true
    },
    game: {
      type: Object,
      required: true,
    },
    currentPlayer: {
      type: Boolean,
      required: true
    },
    nominatedPlayer: {
      type: Object,
      required: true
    }
  },
  data: function () {
    return {
      
    }
  },
  computed: {
    currentPlayerName: function() {
        return this.currentPlayer ? "Your turn" : this.nominatedPlayer.player_name
      },
    currentPlayerScore: function() {
      return this.nominatedPlayer.scores[this.game.set.current_round.round_number]
    },
  },
  methods: {
    
  },
  created () {
    
    
  }
}
</script>

<style scoped lang="scss">

</style>

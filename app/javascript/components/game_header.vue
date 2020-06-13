<template>
  <div class="tile is-ancestor is-vertical">
    <div class="tile">
      <div class="tile is-parent is-7">
        <div class="tile is-child">
          <slot name="game-title"></slot>
          <h2 class="title is-3">{{game.name}}: Game {{game.id}}</h2>
        </div>
      </div>
      <div class="tile is-parent">
        <div class="tile is-child">
          <slot name="game-info"></slot>
          <div v-if="!game.ended"><b>Round: </b>
            <b-tooltip :label="currentRound.instructions" type="is-dark"
              position="is-bottom" multilined size="is-medium">
              <div class="tag is-dark is-small instruction-button">
                  {{currentRound.name}}
              </div>
            </b-tooltip>
          </div>
          <div class=""><b>Number of Clues Left:</b> {{numClues}} </div>
        </div>
      </div>
    </div>
</template>

<script>

export default {
  data: function () {
    return {
      
    }
  }
}
</script>

<style scoped lang="scss">

</style>



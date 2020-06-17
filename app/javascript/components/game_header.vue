<template>
    <div class="vertical-tile">
      <img :src="gameImage" :alt="game.name" :class="['game-image', 'mx-4']" :style="`height:${imageSize}`">
      <span class="is-size-7" v-if="showId">{{game.id}}</span>
    </div>
</template>

<script>

export default {
  props: {
    game: {
      type: Object,
      required: true,
    },
    gameImage: {
      type: String,
      required: false,
    },
    imageSize: {
      type: String,
      required: false,
    },
    showId: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  data: function () {
    return {
      
    }
  }
}
</script>

<style scoped lang="scss">
.game-image {
  height: 70px;
}
</style>



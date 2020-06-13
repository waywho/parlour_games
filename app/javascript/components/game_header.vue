<template>
    <div class="vertical-tile">
      <img :src="gameImage" alt="Fish Bowl" :class="['game-image', 'mx-4']" :style="`height:${imageSize}`">
      <span class="is-size-7">{{game.id}}</span>
    </div>
</template>

<script>

export default {
  props: ['game', 'gameImage', 'imageSize'],
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



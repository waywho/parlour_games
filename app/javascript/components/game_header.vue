<template>
    <div class="vertical-tile">
      <img :src="gameImage" :alt="game.name" :class="['game-image', 'mx-4']" :style="`height:${imageSize}`">
      <span class="is-size-7" v-if="showId">{{game.id}}</span>
    </div>
</template>

<script>
import { mapGetters } from 'vuex';

export default {
  props: {
    game: {
      type: Object,
      required: true,
    },
    imageType: {
      type: String,
      required: false
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
  computed: {
    ...mapGetters({
      getGames: 'getGames'
    }),
    gameImage: function() {
      if(this.imageType == 'logo') {
        return _.find(this.getGames, {name: this.game.name}).logo
      } else {
        return _.find(this.getGames, {name: this.game.name}).image
      }
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



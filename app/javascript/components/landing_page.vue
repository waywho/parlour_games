<template>
  <div class="tile is-ancestor is-vertical">
    <div class="tile is-parent">
      <div class="tile is-child hero-tile">
        <h1 class="title is-1">Welcome to Parlour Games</h1>
      </div>
    </div>
     <div class="tile is-parent">
        <div class="tile is-chid">
          <cookie-law theme="base"></cookie-law>
        </div>
      </div>
  </div>
</template>

<script>
import CookieLaw from 'vue-cookie-law'
export default {
  components: { CookieLaw },
  data: function () {
    return {
      message: "Hello Vue !"
    }
  },
  mounted () {

  }
}
</script>

<style scoped>
.hero-tile {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 75vh;
}


</style>
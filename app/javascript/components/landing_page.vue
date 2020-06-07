<template>
  <div class="tile is-ancestor">
    <div class="tile is-parent hero-tile">
      <div class="tile is-child hero-tile">
        <h1 class="title is-1">Welcome to Parlour Games</h1>
      </div>
    </div>
  </div>
</template>

<script>
export default {
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
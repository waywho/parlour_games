<template>
  <div id="app">
    <app-header></app-header>
    <div class="container ">
      <router-view></router-view>
    </div>
  </div>
</template>

<script>
import header from './components/header.vue'
export default {
  components: {
    'app-header': header
  },
  data: function () {
    return {
    }
  }
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}

.container {
  padding-top: 20px;
}
</style>

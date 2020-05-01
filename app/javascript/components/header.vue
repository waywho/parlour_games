<template>
  <b-navbar type="is-light">
    <template slot="start">
      <b-navbar-item><router-link to="/">Main Page</router-link></b-navbar-item>
      <b-navbar-item><router-link to="/chat">Start chat</router-link></b-navbar-item>
      <b-navbar-item><router-link to="/video_chats">Video chat</router-link></b-navbar-item>
    </template>
  </b-navbar>
</template>

<script>
export default {
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
</style>
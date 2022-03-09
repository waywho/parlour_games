<template>
  <b-navbar spaced shadow>
    <template slot="start">
      <b-navbar-item><router-link to="/">Parlour Games</router-link></b-navbar-item>
      <b-navbar-item v-if="authorisedLinks"><router-link to="/chats">Chats</router-link></b-navbar-item>
      <b-navbar-item><router-link to="/games">Games</router-link></b-navbar-item>
      
    </template>
    <template slot="end">
      <!-- <b-navbar-item v-if="!authorisedLinks"><router-link to="/sign_in">Sign In</router-link></b-navbar-item> -->
      <b-navbar-item v-if="!authorisedLinks"><router-link to="/login">Sign In</router-link></b-navbar-item>
      <b-navbar-item v-if="!authorisedLinks"><router-link to="/sign_up">Register</router-link></b-navbar-item>
      <b-navbar-dropdown :label="currentUser.name" v-if="authorisedLinks">
        <b-navbar-item v-if="authorisedLinks"><router-link to="/my_games">My Games</router-link></b-navbar-item>
        <b-navbar-item v-if="authorisedLinks" @click="signOut">Sign Out</b-navbar-item>
      </b-navbar-dropdown>
    </template>
  </b-navbar>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  data: function () {
    return {
    
    }
  },
  computed: {
    ...mapGetters({
      currentUser: 'currentUser',
      authorisedLinks: 'authenticated'
    })
  },
  methods: {
    signOut: function() {
      this.$store.dispatch('destroyToken')
        .then(res => {
          this.$router.push({name: 'signIn'})

        })
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

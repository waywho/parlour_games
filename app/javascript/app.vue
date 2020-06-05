<template>
  <div id="app">
    <app-header></app-header>
    <div class="container ">
      <b-notification class="bottom-note" type="is-success" :active.sync="isActive" aria-close-label="Close notification" v-show="showNotification"><notification v-if="authenticated" v-on:new-note="showNote"></notification></b-notification>
      <router-view :key="$route.path"></router-view>
    </div>
  </div>
</template>

<script>
import header from './components/header.vue'
import notification from './components/notification.vue'
import { mapGetters } from 'vuex'
export default {
  components: {
    'app-header': header,
    'notification': notification
  },
  computed: {
    ...mapGetters(['authenticated']),
    showNotification: function() {
      return this.$store.getters.authenticated && this.isActive
    }
  },
  data: function () {
    return {
      isActive: false
    }
  },
  methods: {
    showNote: function() {
      this.isActive = true
    }
  },
  mounted() {
    
    
  }
}
</script>

<style lang="scss">
@import './styles/global.scss';

</style>
<style scoped>
p {
  font-size: 2em;
  text-align: center;
}

.container {
  padding-top: 20px;
}

.bottom-note {
  position: fixed;
  max-width: 250px;
  width: 250px;
  bottom: 0px;
  right: 10px;
  z-index: 10;
}
</style>

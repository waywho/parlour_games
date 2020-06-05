<template>
  <div class="tile is-ancestor wrap-tile">
    
    <div class="tile is-parent is-4" v-for="game in games">
        <div class="tile is-child card">
        <header class="card-header">
          <p class="card-header-title">
            {{game.name}}
          </p>
          <a href="#" class="card-header-icon" aria-label="more options">
            <span class="icon">
              <i class="fas fa-angle-down" aria-hidden="true"></i>
            </span>
          </a>
        </header>
        <div class="card-content">
          <div class="content">
            <span v-for="session in game.game_sessions">{{ session.user.name }}<br /></span>
            <br>
            <time datetime="2016-1-1">{{game.updated_at | human-date }}</time>
          </div>
        </div>
        <footer class="card-footer">
          <a href="#" class="card-footer-item">Play</a>
          <a href="#" class="card-footer-item">Delete</a>
        </footer>
      </div>
    </div>
    
  </div>
</template>

<script>
import parlourAxios from '../axios/axios_parlour.js';

export default {
  components: {

  },
  data: function () {
    return {
      games: null
    }
  },
  created() {
    parlourAxios.get('/games?type=my').then(res => {
          // console.log('chatrooms serach', res.data)
          this.games = res.data
        })
  }
}
</script>

<style scoped>

.wrap-tile {
   flex-wrap: wrap;
}
</style>

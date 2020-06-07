<template>
  <div class="tile is-ancestor wrap-tile">
    <h2 class="title is-2">My Games</h2>
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
          <div class="content tags">
            <span class="tag is-dark" v-for="session in game.game_sessions">{{ session.player_name }}<br /></span>
          </div>
        </div>
        <footer class="card-footer">
          <a href="" class="card-footer-item item-hover" @click="goToGame(game.name, game.id)"><b>Play</b></a>
          <span class="card-footer-item"><time datetime="2016-1-1">{{game.updated_at | human-date }}</time></span>
        </footer>
      </div>
    </div>
    
  </div>
</template>

<script>
import parlourAxios from '../axios/axios_parlour.js';
import goToGame from '../mixins/goToGame';

export default {
  mixins: [goToGame],
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

.item-hover:hover {
  background-color: #363636;
  color: #fff;
}

.card-content {
  height: 100px;
  overflow: scroll;
}
</style>

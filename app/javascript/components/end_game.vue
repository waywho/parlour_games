<template>
  <div class="tile">
    <score-board :teams="game.teams" :rounds="game.rounds"></score-board>
       <div class="firework-rounded">
          <div class="firework-rounded-light"></div>
          <div class="firework-rounded-light"></div>
          <div class="firework-rounded-light"></div>
          <div class="firework-rounded-light"></div>
          <div class="firework-rounded-light"></div>
          <div class="firework-rounded-light"></div>
          <div class="firework-down"></div>
      </div>

  </div>
</template>

<script>
import scoreBoard from './score_board'
export default {
  props: ['game'],
  data: function () {
    return {
      
    }
  },
  components: {
    'score-board': scoreBoard
  },
  methods: {
    reMatch: function() {
    let newGame = this.game
    delete newGame.id
    parlourAxios.post('/games', {game: {name: newGame} })
      .then(res => {
        const host = res.data.hosts.filter(host => {
          return host.playerable_id == this.$store.getters.currentUser.id
        })[0]
        this.$store.dispatch('resetGameSession', host)
        this.currentGameId = res.data.id 
        this.currentGameName = this.$options.filters.camelToUnderscore(res.data.name)
      })   
    },
  },
  created () {
    
    
  }
}
</script>

<style scoped>
.firework-rounded{
  position: fixed;
    width: 150px;
    height: 150px;
    top: 40%;
    left: 50%;
    transform: translate(-50%, -50%) scale(2);
}
.firework-rounded.big{
  transform: scale(2) translateX(-25%) !important;
}
.firework-rounded-light{
  margin: 0;
  position: absolute;
  top: 50%;
  left: 50%;
  -ms-transform: translate(-50%, -50%);
  transform: translate(-50%, -50%);
  border-radius:50%;
  border-color: #363636 !important;
  animation: fireworksAnimation 1.2s  1s ease-out  alternate;
  opacity: 0;
  animation-iteration-count: 2;
}
.firework-rounded-light:nth-child(1){
  width:30px;
  height: 30px;
  border:1px dotted ;
  animation-delay:1.1s;
  
}
.firework-rounded-light:nth-child(2){
  width:50px;
  height: 50px;
  border:2px dotted;
  animation-delay:1.2s;
}
.firework-rounded-light:nth-child(3){
  width:70px;
  height: 70px;
  border:4px dotted;
   animation-delay:1.3s;
}
.firework-rounded-light:nth-child(4){
  width:100px;
  height: 100px;
  border:6px dotted;
  animation-delay:1.4s;
  transform: translate(-50%, -50%) rotate(45deg);
}
.firework-rounded-light:nth-child(5){
  width:130px;
  height: 130px;
  border:8px dotted;
   animation-delay: 1.6s;
   transform: translate(-50%, -50%) rotate(45deg);
}
.firework-rounded-light:nth-child(6){
  width:160px;
  height: 160px;
  border:10px dotted;
   animation-delay: 1.8s;
   transform: translate(-50%, -50%) rotate(90deg);
}
.firework-down {
    position: absolute;
    height: 100%;
    width: 0;
    bottom: -110%;
    border: 1px dotted #363636;
    left: 48.44%;
    animation: fireworksDown 1.6s cubic-bezier(0, 0, 0.2, 1) alternate;
    opacity: 0;
    top: 200%;
}
  .firework-rounded:after {
    content: '*';
    position: absolute;
    width: 25px;
    height: 25px;
    font-size: 20px;
    left: 55%;
    top: 53%;
    transform: translate(-50%, -50%);
    color: #363636;
    animation: fireworksStar 1.2s 1s cubic-bezier(0, 0, 0.2, 1) alternate-reverse;
    opacity: 0;
}
/*Animation */
@keyframes fireworksAnimation {
  0%,100%{
    opacity: 0;
    border-color: #ee1284;
  }
  50%{
    opacity: 0.5;
    border-color: #ee1284;
  }
  75%{
    opacity: 1;
    border-color: #ee1284;
  }
}
@keyframes fireworksStar {
  0%,100%{
    opacity:0;
  }
  50%{
    opacity: 0.5;
  }
  75%{
    opacity: 1;
  }
}
@keyframes fireworksLight {
  0%,100%{
    height:0;
    opacity:0;
  }
  50%{
   height: 100%;
   opacity:1;
  }
}
@keyframes fireworksDown {
  0%,100%{
    opacity:0;
    top: 200%
  }
  50%{
    top: 50%;
    opacity:1;
  }
  60%{
    top: 50%;
    opacity:0.8;
  }
  70%{
    top: 50%;
    opacity:0.6;
  }
  80%{
    top: 50%;
    opacity:0.4;
  }
  90%{
    top: 50%;
    opacity:0.2;
  }
  91%{
    top:50%;
    opacity: 0;
  }
}
*, :after, :before {
    box-sizing: border-box;
    position: relative;
}


</style>

<template>
  <div class="tile">
    <div class="tile is-vertical" v-if="!cluesSubmitted">
      <game-header :game="game" :game-image="gameImage" :image-size="'100px'"></game-header>
      <div class="tile is-parent card-pot">
        <div class=" tile is-child card-stack">
          <game-paper v-for="(c, index) in 3" :key="index" v-model="currentClue" :ref="'clue_' + index" :clue="currentClue" @input="enableButton"></game-paper>
        </div>
      </div>

      <div class="tile is-parent is-vertical">
        <div class="tile is-child center-tile ">
          <b-button class="clue-button" type="is-dark" @click="parkClue" :disabled="disableAdd">Next Clue</b-button>
        </div>
        <div class="tile is-child tags center-tile">
          <span class="tag is-outlined" v-for="(clue, index) in cluesToAdd">{{clue}}</span>
        </div>
        <div class="tile is-child center-tile">
          <b-button class="clue-button" type="is-dark" outlined @click="submitClues">{{addButtonMessage}}</b-button>
        </div>
      </div>
    </div>

    <div class="tile is-vertical" v-else>
      <div class="tile is-parent is-vertical">
        <div class="tile is-child">
          <i>Waiting to start the game</i>
        </div>
        <div class="tile is-child">
          <b-button type="is-dark start-button" @click="startGame" v-if="currentHost">Host to Start Game</b-button>
        </div>
      </div>

      <div class="tags are-medium tile is-parent" v-if="submittedPlayers.length > 0">
        <div class="tile is-child box">
          <div class="title is-4">Players submitted clues</div>
          <div :class="['tag', session.host ? 'is-info' : 'is-dark', session.invitation_accepted ? '' : 'is-light']" v-for="session in submittedPlayers" :key="session.id">
            {{session.player_name}}{{ session.host ? ' (host)' : ''}}
          </div>
        </div>

        <div class="tile is-child box">
          <div class="title is-4">Waiting from these Players</div>
          <div :class="['tag', session.host ? 'is-info' : 'is-dark is-light']" v-for="session in notSubmittedPlayers" :key="session.id">
            {{session.player_name}}{{ session.host ? ' (host)' : ''}}
          </div>
        </div>
      </div>

    </div>
    
  </div>
</template>

<script>
import gameAxios from '../axios/axios_game_update.js';
import gameCard from './game_card';
import gamePaper from './game_paper';
import draggable from 'vuedraggable';
import gameHeader from './game_header';
import fishbowlImage from '../assets/fish-bowl-logo.png'

export default {
	props: ['game', 'currentHost', 'gameSession'],
  components: {
    'game-card': gameCard,
    'game-paper': gamePaper,
    'draggable': draggable,
    'game-header': gameHeader
  },
  data: function () {
    return {
      currentGame: null,
      clues: ["", "", ""],
      cluesToAdd: [],
      clueNumbers: 5,
      currentClue: "",
      disableAdd: true,
      gameImage: fishbowlImage
    }
  },
  computed: {
    addButtonMessage: function() {
      if(this.cluesToAdd == 0) {
        return "I don't want to add any clues"
      } else {
        return `I'm done! Add it all to the ${this.game.name}!`
      }
    },
    cluesSubmitted: function() {
      if(_.includes(this.game.set.players_gone, this.gameSession.id)) {
        return true
      } else {
        return false
      }
    },
    submittedPlayers: function() {
      let playerArr = []
      let playersGone = this.game.set.players_gone
      _.forEach(this.game.game_sessions, function(session) {
        if(_.includes(playersGone, session.id)) {
          playerArr.push(session)
        }
      })
      return playerArr
    },
    notSubmittedPlayers: function() {
      let playerArr = []
      let playersGone = this.game.set.players_gone
      _.forEach(this.game.game_sessions, function(session) {
        if(!_.includes(playersGone, session.id)) {
          playerArr.push(session)
        }
      })
      return playerArr
    }
  },
  methods: {
    enableButton: function() {
      this.disableAdd = false
    },
    startGame: function() {
      let startGame = false
      if(this.game.set.players_gone.length < this.game.game_sessions.length) {
        startGame = confirm('Are you sure you want to start? Not all players have submitted their clues?')
      } else {
        startGame = true
      }
      console.log('start game', startGame)

      if(startGame) {
        console.log('starting game')
        let gameSet = this.game.set
        gameSet.current_round.completed = true
        console.log(gameSet)
        this.$store.dispatch('updateGame', {id: this.game.id, set: gameSet}).then(res => {
          console.log('dispatched update', res)
        })
      }
    },
    parkClue: function() {
      if(this.currentClue != "" || this.currentClue != null || this.currentClue != undefined) {
        this.cluesToAdd.push(this.currentClue)
        this.currentClue = ""
        this.disableAdd = true
        this.$refs.clue_2[0].$el.children[0].focus()
      }
    },
    submitClues: function() {
      if(this.currentClue != null || this.currentClue != undefined) {
        this.cluesToAdd.push(this.currentClue)
      }
      var clueArray = this.cluesToAdd.map(clue => {
        return clue.trim()
      })
      clueArray = _.uniq(clueArray)
      var filterClueArray = clueArray.filter(clue => {
        return clue != ""
      })
      console.log(filterClueArray)

      gameAxios.put(this.game.id.toString(), {game: {set: {clues: filterClueArray, players_gone: [this.gameSession.id] }}})
        .then(res => {
          console.log('populate pot')
          // this.currentGame = res.data
        })
    }
  },
  created() {
    this.currentGame = this.game
    console.log('host prop', this.currentHost)
    
    
  }
}
</script>

<style scoped lang="scss">
@import '../styles/global.scss';

.center-tile {
  display: flex;
  align-items: center;
  justify-content: center;
}


</style>

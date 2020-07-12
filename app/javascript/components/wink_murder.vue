<template>
  <div class="columns is-multiline is-gapless is-mobile">
    <div class="column tile is-ancestor is-half-desktop is-full-tablet is-full-mobile">
      <div class="tile is-parent is-vertical">
        <div class="tile is-child">
          <game-header class="game-header" :game="game"></game-header>
        </div>
      
        <div class="tile is-child center-tile">
          <b-taglist attached class="no-margin">
            <b-tag type="is-dark" size="is-medium">{{playerOrMurderer}}</b-tag>
            <!-- <b-tag type="is-light" size="is-medium" class='light-tag' v-if="asMurderer"></b-tag> -->
          </b-taglist>  
        </div>
        <div class="tile is-child">
          <div v-if="playerView" class="carousel-container">
          <transition  name="fade" mode="out-in">
            <div v-if="currentPlayerOut" class="card player-card is-regular has-background-dark" key="out" :class="[currentPlayerOut ? 'dying' : '']">
            </div>
            <div v-else key="alive">
              <b-carousel :indicator="false" :autoplay="autoPlay" v-model="player">
                <b-carousel-item v-for="(session, index) in otherPlayers" :key="session.id">
                  <div class="card player-card is-regular tile is-vertical" :class="[session.out ? 'delay-dying' : '']">
                    <div class="card-image center-tile card-eye">
                      
                      <eye v-if="!session.out" :open-eye="openEye" :session-looking="session.looking" :prepend="'main'" :session="session" :index="index" :key="index" :ref="'mainEye' + session.id" :size="100"></eye>
                    </div> 
                    <div class="card-content card-divider">
                      <div class="content has-text-centered title is-4">
                        {{session.player_name}}
                      </div>
                    </div>
                  </div>
                </b-carousel-item>
              </b-carousel>
              <div class="buttons  pt-1 center-tile wrap-tile">
                  <b-button v-for="(player, index) in otherPlayers" type="is-dark" size="is-small" outlined :key="index" @click="lookPlayer(index)" :disabled="disableActions">
                    {{player.player_name}}
                  </b-button>
              </div>
            </div>
          </transition>
          </div>
          <div v-if="!playerView" class="columns is-multiline is-mobile">
            <div v-for="(session, index) in players" class="column is-one-quarter-tablet is-one-third-mobile">

              <div class="player-card is-small-card" :class="[session.out ? 'dying' : '']">
                <div class="card-image center-tile card-eye" >
                  <eye v-if="!session.out" :open-eye="true" :session-looking="true" :prepend="'group'" :session="session" :index="index" :ref="'smallEye' + session.id" :size="60"></eye>
                </div>
                <div class="card-content card-divider py-1 px-0">
                  <div class="content has-text-centered">
                    {{session.player_name}}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="tile is-child">
          <div v-if="!currentPlayerOut" class="control has-text-centered">
            <b-button type="is-dark" @click="randomPlayer" :disabled="disableActions">Any</b-button>
            <b-button type="is-dark" @click="nextPlayer" :disabled="disableActions">Next</b-button>
            <b-button v-if="asMurderer" type="is-danger" @click="kill">kill</b-button>
            <b-button v-else type="is-dark" @click="phaseUpdate('first')" :disabled="disableActions">I Accuse</b-button>
            
<!--             <b-button type="is-danger" @click="blinkEye()">blink</b-button> -->
<!--             <b-button type="is-danger" @click="() => { this.out = true}">dying</b-button> -->
          </div>
          <div v-else class="control has-text-centered">
            <b-button v-if="!playerView" type="is-dark" @click="() => {playerView = true}">player view</b-button>
            <b-button v-if="playerView" type="is-dark" @click="() => {playerView = false}">group view</b-button>
          </div>
        </div>
      </div>
    </div>
    <div class="column is-half-desktop is-full-tablet is-full-mobile">
      <div class="columns is-multiline">
        <div class="column is-full">
          <div class="title is-5 section-line">
              Score Board
          </div>
        </div>
        <div class="column is-full">
          <score-board :teams="game.game_sessions" :rounds="game.set.rounds_played" :total-only="true" class="is-fullwidth"></score-board>
        </div>
        <div class="column is-full">
          <div class="title is-5 section-line">
              Players
          </div>
        </div>
        <div class="column is-full">
          <div class="tags are-medium">
            <player v-for="session in game.game_sessions" :key="session.id" :game-session="session" :currentHost="currentHost" class="is-dark"></player>
          </div>
        </div>
      </div>
    </div>
    <round-notice ref="roundNotice" :current-round="currentRound" :game="game" :showScores="true" :scoring-parties="game.game_sessions" :enable-next-round="currentHost" key="roundNotice"></round-notice>
    <challenge-notice ref="challengeNotice" :current-round="game.set.current_round" :game="game" v-on:update-phase="phaseUpdate" :game-session="gameSession" :key="challengeKey"></challenge-notice>
  </div>
</template>

<script>
import gameBehaviours from '../mixins/gameBehavioursMixin'
import roundNotice from './round_notice';
import challengeNotice from './wm_challenge_notice';
import gameHeader from './game_header';
import gameCard from './game_card';
import { bus } from '../packs/application';
import eye from './eye'
import scoreBoard from './score_board';
import player from './player';

export default {
  props: {
    game: {
      type: Object,
      required: true
    },
    gameSession: {
      type: Object,
      required: false,
    },
    currentHost: {
      type: Boolean,
      required: false
    },
    gameSubscription: {
      type: Object,
      required: false,
    }
  },
  components: {
    'round-notice': roundNotice,
    'game-header': gameHeader,
    'game-card': gameCard,
    'eye': eye,
    'challenge-notice': challengeNotice,
    'score-board': scoreBoard,
    'player': player,
  },
  mixins: [gameBehaviours],
  data: function () {
    return {
      autoPlay: false,
      player: 0,
      blink: false,
      openEye: false,
      players: [],
      currentGame: null,
      playerView: true,
      roundName: null,
      instructions: null,
      out: false,
      outPlayers: {},
      playerDying: false,
      challengeKey: 0
      // otherPlayers: []
    }
  },
  computed: {
    currentRound: function() {
      return {
        name: this.roundName,
        instructions: this.instructions
      }
    },
    murderers: function() {
      let murderers = []
      this.game.set.current_round.murderers.forEach(id => {
        murderers.push(_.find(this.game.game_sessions, {id: id}))
      })
      return murderers
    },
    outList: function() {
      let arrs = Object.values(this.outPlayers)
      return arrs.flat(1)
    },
    playerLooking: function() {
      return this.otherPlayers.map((player) => {
        return _.includes(this.lookers, player.id)
      })
    },
    otherPlayers: {
      get: function() {
        let sessions = this.players.filter(session => {
          return session.id != this.gameSession.id && !_.includes(this.outList, session.id)
        })
        sessions.forEach(session => {
          this.$set(session, 'looking', _.includes(this.lookers, session.id))
        })
        return sessions
      },
      set: function(newValue) {
        this.players = newValue 
      }
    },
    asMurderer: function() {
      return _.includes(this.game.set.current_round.murderers, this.gameSession.id)
    },
    playerOrMurderer: function() {
      return this.asMurderer ? 'You are the Wink Murderer' : this.gameSession.player_name
    },
    currentPlayerOut: function() {
      return _.includes(this.outList, this.gameSession.id)
    },
    lookingAt: function() {
      return this.otherPlayers[this.player]
    },
    lookers: function() {
      return this.game.turn_order.lookers[this.gameSession.id]
    },
    lastLookedAt: function() {
       return Number(_.findKey(this.game.turn_order.lookers, (o) => { return _.includes(o, this.gameSession.id)}))
    },
    disableActions: function() {
      if(this.playerDying) {
        return true
      } else if (this.outList.length == (this.game.game_sessions.length - 1)) {
        return true
      } else if (this.game.set.current_round.phase != 'winking') {
        return true
      } else {
        return false
      }
    }
  },
  watch: {
    game(newVal, oldVal) {
      console.log('game old val', oldVal)
      if (newVal.set.current_round.phase == 'winking') {
        this.$refs.challengeNotice.close()
      } else if (newVal.set.current_round.phase == 'seconder-seeking') {

        this.$refs.challengeNotice.activate()
        return
      }

      if (newVal.set.current_round.completed) {
        this.roundName = "Round " + newVal.set.current_round.round_number + " Finished"
        this.instructions = `Murderer(s): ${_.map(this.murderers, (o) => { return o.player_name }).join(", ")}`
      } else if (newVal.set.current_round.round_number > oldVal.set.current_round.round_number || newVal.set.current_round.completed != oldVal.set.current_round.completed) {
        console.log('resetting game', newVal)
        
        this.resetGame();
        this.$refs.roundNotice.close()
        this.setLastLookedAt()
      } else {
        console.log("new outlist", newVal.set.current_round.out_list)
        console.log("old outlist", newVal.set.current_round.out_list)

        let newOutList = Object.values(newVal.set.current_round.out_list).flat(1)
        let oldOutList = Object.values(oldVal.set.current_round.out_list).flat(1)
        let diffOutList = _.difference(newOutList, oldOutList)
        console.log(diffOutList)
        
        if(!_.isEmpty(diffOutList)) {
          if(_.includes(newOutList, this.gameSession.id)) {
            this.blinkEye(newVal.turn_order.current_turn.murderer) 
          }

          console.log('diff out list', diffOutList)
          diffOutList.forEach(outId => {
            var player = _.find(this.players, {id: outId})
            player.out = true
            console.log('player out', player)
          })

          if(_.includes(diffOutList, this.gameSession.id)) {
            this.playerDying = true
          }

          // if all players are killed end the game right away
          var timeDelay = 0
          if(newOutList.length != this.game.game_sessions.length) {
            timeDelay = 2500
          }

          setTimeout(() => {
            console.log('i was looking at him', this.lastLookedAt)
            console.log('included', _.includes(newOutList, this.lastLookedAt))
            
            this.outPlayers = newVal.set.current_round.out_list

            if(_.includes(newOutList, this.lastLookedAt)) {
              var randNum = Math.floor(Math.random() * this.otherPlayers.length)
              this.player = randNum
              this.looking()
            }
            // this will trigger current player dying
            
          }, timeDelay)
        }
      }

      // TODO else takes the bus emit function
    }
  },
  methods: {
    resetGame: function() {
      this.players = this.game.game_sessions
      this.playerView = true
      this.playerDying = false
      this.outPlayers = this.game.set.current_round.out_list
      this.players.forEach((player) => {
        player.out = _.includes(this.outList, player.id)
      })
    },
    setLastLookedAt: function() {
      const lastLookedAt = this.lastLookedAt

      // console.log("looking at", lastLookedAt)
      // console.log(this.otherPlayers)
      // console.log("is it in the gorup?", _.includes(this.otherPlayers, {id: lastLookedAt}))

      const player_ids = _.map(this.otherPlayers, 'id')
      if(_.includes(player_ids, lastLookedAt)) {
        this.otherPlayers.forEach((player, index) => {
          if(player.id == lastLookedAt) {
            this.player = index
          }
        })  
      } else {
        var randNum = Math.floor(Math.random() * this.otherPlayers.length)
        this.player = randNum
        this.looking()
      }
    },
    blinkEye: function(murdererId) {
      console.log('blink', murdererId)
      bus.$emit('blink', murdererId)
    },
    lookPlayer: function(index) {
      this.player = index
      this.looking()
    },
    looking: function() {
      console.log(`looking ${this.player}`)

      this.$store.dispatch('updateGame', {
        id: this.game.id,
        looking_turn: { looker: this.gameSession.id, lookee: this.lookingAt.id },
      }).then(res => {
        // console.log('dispatched update received', res)
      })
      
    },
    phaseUpdate: function(accuserOrder) {

      var accusations = this.game.turn_order.accusations
      
      accusations[accuserOrder].accuser = this.gameSession.id
      
      this.$store.dispatch('updateGame', {
        id: this.game.id,
        accusations: accusations
      }).then(res => {
        // console.log('dispatched update received', res)
      })
    },
    kill: function() {
      let playerToKill = this.otherPlayers[this.player]
      console.log("kill player", playerToKill)
      this.gameSubscription.killing(this.gameSession.id)

      let notMurderer = !_.includes(this.game.set.current_round.murderers, playerToKill.id)
      console.log('not murderer', notMurderer)
      if(playerToKill.looking && notMurderer) {
        this.$store.dispatch('updateGame', {
          id: this.game.id,
          current_turn: { outed: playerToKill.id,  murderer: this.gameSession.id }
        }).then(res => {
          // console.log('dispatched update received', res)

        })
      }
    },
    nextPlayer: function() {
      if(this.player < (this.otherPlayers.length - 1) ) {
        this.player += 1
      } else {
        this.player = 0
      }
      this.looking()
    },
    randomPlayer: function() {
      var randNum = Math.floor(Math.random() * this.otherPlayers.length)
      if (this.player == randNum) {
        if(randNum == (this.otherPlayers.length - 1)) {
          this.player = 0
        } else {
          this.player = randNum + 1
        }
      } else {
        this.player = randNum
      }
      this.looking()
    },
  },
  mounted() {
    if(this.game.set.current_round.completed) {
      this.$refs.roundNotice.activate()
    }
    if(this.game.set.current_round.phase != 'winking') {
      this.$refs.challengeNotice.activate()
    }
  },
  created () {
    this.outPlayers = this.game.set.current_round.out_list
    this.resetGame();
    this.setLastLookedAt();
    // this.player = Math.floor(Math.random() * this.otherPlayers.length)
    // setTimeout(() => {
    //   this.looking()
    // }, 3000)
    // bus.$on('looking', (looker) => {
    //   this.lookers.push(looker)
    //   console.log(`lookers ${this.lookers}`)
    // })
    // bus.$on('not_looking', (looker) => {
    //   let index = this.lookers.indexOf(looker)
    //   if (index > -1) {
    //     this.lookers.splice(index, 1)
    //   }
    //   console.log(`lookers ${this.lookers}`)
    // })
    bus.$on('killing', (killer) => {
      if(this.lookingAt.id == killer) {
        this.openEye = true
        this.blinkEye(killer)
        setTimeout(() => {
          this.openEye = false
        }, 300)
      }

    })

  }
}
</script>

<style scoped lang="scss">

.player-card {
  border-radius: 15px;
  color: black;
  border: 1px solid black;
  margin: auto;
}

.carousel-container {
  min-height: 422px;
}

.is-regular {
  width: 280px;
  height: 380px;
  min-height: 380px;
}

.is-small-card {
  height: 150px;
}

.card-eye {
  height: 80%;
  min-height: 80%;
}

.test-scale {
  transform: scaleY(0.5);
}

.card-divider {
  border-top: 1px solid #363636;
}

.card-divider-light {
  border-top: 1px solid white;
}

.horizontal-center {
  justify-content: center;
}

.fade-enter-active, .fade-leave-active {
  transition: opacity 1s;
}
.fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
  opacity: 0;
}

.delay-dying {
  animation: delay-dying 4s;
  background-color: #f14668;
}

.dying {
  animation: dying 1s;
  background-color: #f14668;
}

@keyframes dying {
  0% {
    border-color: #f14668;
    background-color: #f14668;
  }
  40% {
    border-color: #f14668;
    background-color: #f14668;
  }
  100% {
    border-color: #363636;
    background-color: #363636;
  }
}

@keyframes delay-dying {
  75% {
    border-color: #f14668;
    background-color: #f14668;
  }
  100% {
    border-color: #363636;
    background-color: #363636;
  }
}


</style>

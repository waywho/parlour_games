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
          <div v-if="playerView">
          <transition  name="fade" mode="out-in">
            <div v-if="dead" class="card player-card is-regular has-background-dark" key="dead" :class="[dead ? 'dying' : '']">
            </div>
            <div v-else key="alive">
              <b-carousel :indicator-inside="false" :autoplay="autoPlay" v-on:change="looking"  v-model="player">
                <b-carousel-item v-for="(session, index) in otherPlayers" :key="session.id">
                  <div class="card player-card is-regular tile is-vertical">
                    <div class="card-image center-tile card-eye">
                      
                      <eye :open-eye="openEye" :session-looking="session.looking" :prepend="'main'" :session="session" :index="index" :key="index" :ref="'mainEye' + session.id" :size="100"></eye>
                    </div> 
                    <div class="card-content card-divider">
                      <div class="content has-text-centered title is-4">
                        {{session.player_name}}
                      </div>
                    </div>
                  </div>
                </b-carousel-item>
                <template slot="indicators" slot-scope="props">
                  <span class="tag is-medium is-dark">
                    {{otherPlayers[props.i].player_name}}
                  </span>
                </template>
              </b-carousel>
            </div>
          </transition>
          </div>
          <div v-if="!playerView" class="columns is-multiline is-mobile">
            <div v-for="(session, index) in players" class="column is-one-quarter-tablet is-one-third-mobile">
              <div v-if="session.dead" class="card player-card is-small has-background-dark" key="dead" :class="[dead ? 'dying' : '']">
                <div class="card-image center-tile card-eye">
                  
                </div>
                <div class="card-content card-divider-light py-1 px-0">
                  <div class="content has-text-centered has-text-light">
                    <b>{{session.player_name}}</b>
                  </div>
                </div>
              </div>
              <div v-else class="player-card is-small">
                <div class="card-image center-tile card-eye">
                  <eye :open-eye="true" :session-looking="true" :prepend="'group'" :session="session" :index="index" :ref="'smallEye' + session.id" :size="60"></eye>
                </div>
                <div class="card-content card-divider py-1 px-0">
                  <div class="content has-text-centered">
                    <b>{{session.player_name}}</b>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="tile is-child">
          <div v-if="!dead" class="control has-text-centered">
            <b-button type="is-dark" @click="randomPlayer">any</b-button>
            <b-button type="is-dark" @click="nextPlayer">next</b-button>
            <b-button v-if="asMurderer" type="is-danger" @click="kill">kill</b-button>
<!--             <b-button type="is-danger" @click="blinkEye()">blink</b-button> -->
<!--             <b-button type="is-danger" @click="() => { this.dead = true}">dying</b-button> -->
          </div>
          <div v-else class="control has-text-centered">
            <b-button v-if="!playerView" type="is-dark" @click="() => {playerView = true}">player view</b-button>
            <b-button v-if="playerView" type="is-dark" @click="() => {playerView = false}">group view</b-button>
          </div>
        </div>
      </div>
    </div>
    <div class="column is-half-desktop is-full-tablet is-full-mobile">
      asdf
    </div>
    <round-notice :current-round="currentRound" :game="game" :showScores="true" :scoring-parties="murderers" :enable-next-round="currentHost"></round-notice>
  </div>
</template>

<script>
import gameBehaviours from '../mixins/gameBehavioursMixin'
import roundNotice from './round_notice';
import winkImage from '../assets/wink-glow.png';
import gameHeader from './game_header';
import gameCard from './game_card';
import { bus } from '../packs/application';
import eye from './eye'

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
    'eye': eye
  },
  mixins: [gameBehaviours],
  data: function () {
    return {
      gameImage: winkImage,
      autoPlay: false,
      player: 0,
      lookers: [],
      blink: false,
      openEye: false,
      players: [],
      currentGame: null,
      playerView: true
      // dead: false
      // otherPlayers: []
    }
  },
  computed: {
    currentRound: function() {
      return {
        name: this.game.set.current_round.round_number,
        instructions: ""
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
      let arrs = Object.values(this.game.set.current_round.out_list)
      return arrs.flat(1)
    },
    playerLooking: function() {
      return this.otherPlayers.map((player) => {
        return _.includes(this.lookers, player.id)
      })
    },
    otherPlayers: function() {
      var sessions = this.game.game_sessions.filter(session => {
        return session.id != this.gameSession.id && !_.includes(this.outList, session.id)
      })

      sessions.forEach(session => {
        session.looking = _.includes(this.lookers, session.id)
      })

      // console.log('sessions', sessions)
      return sessions
      // _.filter(this.players, (o) => { o.id != this.gameSession.id } )
    },
    asMurderer: function() {
      return _.includes(this.game.set.current_round.murderers, this.gameSession.id)
    },
    playerOrMurderer: function() {
      return this.asMurderer ? 'You are the Wink Murderer' : this.gameSession.player_name
    },
    dead: function() {
      return _.includes(this.outList, this.gameSession.id)
    },
    lookingAt: function() {
      return this.otherPlayers[this.player]
    }
  },
  watch: {
    game(newVal, oldVal) {
      if(newVal.turn_order.current_turn.outed == this.gameSession.id) {
        this.blinkEye(newVal.turn_order.current_turn.murderer)
      }
      this.players = newVal.game_sessions
      this.players.forEach(session => {
        session.dead = _.includes(this.outList, session.id)
      })
      // TODO else takes the bus emit function
    }
  },
  methods: {
    blinkEye: function(murdererId) {
      console.log('blink', murdererId)
      bus.$emit('blink', murdererId)
    },
    looking: function() {
      console.log(`looking ${this.player}`)
      // console.log(`player ${this.otherPlayers[e].id}`)
      // let lookingId = this.otherPlayers[e].id
      // console.log(`player ${lookingId}`)
      if(this.lookingAt != null || this.lookingAt != undefined) {
        this.gameSubscription.looking(this.lookingAt.id, this.gameSession.id)
      }
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
          turn_order: { current_turn: { outed: playerToKill.id,  murderer: this.gameSession.id }}
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
    },
    randomPlayer: function() {
      var randNum = Math.floor(Math.random() * this.otherPlayers.length)
      if (this.player == randNum) {
        if(randNum = (this.otherPlayers.length - 1)) {
          this.player = 0
        } else {
          this.player = randNum + 1
        }
      } else {
        this.player = randNum
      }
    },
  },
  created () {
    this.players = this.game.game_sessions
    this.players.forEach(session => {
      session.dead = _.includes(this.outList, session.id)
    })

    this.player = Math.floor(Math.random() * this.otherPlayers.length)
    setTimeout(() => {
      this.looking()
    }, 3000)
    bus.$on('looking', (looker) => {
      this.lookers.push(looker)
      console.log(`lookers ${this.lookers}`)
    })
    bus.$on('not_looking', (looker) => {
      let index = this.lookers.indexOf(looker)
      if (index > -1) {
        this.lookers.splice(index, 1)
      }
      console.log(`lookers ${this.lookers}`)
    })
    bus.$on('killing', (killer) => {
      if(this.lookingAt.id == killer) {
        this.openEye = true
        this.blinkEye(killer)
        setTimeout(() => {
          this.openEye = false
        }, 250)
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

.is-regular {
  width: 280px;
  height: 380px;
}

.is-small {
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

.dying {
  animation: dying 6s;
}

@keyframes dying {
  0% {
    border-color: #f14668;
    background-color: #f14668;
  }
  100% {
    border-color: #363636;
    background-color: #363636;
  }
}


</style>

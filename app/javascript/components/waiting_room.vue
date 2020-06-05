<template>
  <div>
  	<h2 class="title is-2">{{currentGame.name}} {{currentGame.id}}</h2>
    <h3 class="subtitle is-4"><i>Waiting Room{{ currentGame.started ? ': this game has started' : ''}}</i></h3>
    <div class="tile is-ancestor">
      <div class="tile is-parent">
        <div class="field tile is-child" v-if="currentHost">
          <b-switch v-model="currentGame.team_mode" :disabled="!currentHost" @input="removeTeams" type="is-dark">
              turn on team mode
          </b-switch>
        </div>
        <div v-if="currentGame.team_mode && !currentHost" class="tile is-child">
          Number of teams: {{numberOfTeams}}
        </div>
        <b-field class="tile is-child" label="Create Teams" v-if="currentGame.team_mode && currentHost">
          <b-input placeholder="Number of teams" type="number" v-model="teamNumbers"></b-input>
          <p class="control">
              <b-button class="button is-dark" @click='createTeams' :disabled="!currentHost">Create</b-button>
          </p>
        </b-field>
        <div class="tile is-child buttons">
          <b-button type="is-dark" @click="startGame" v-if="currentHost && !currentGame.started" :disabled="!allAccepted && teamsAssigned">Start Game</b-button>
        </div>

      </div>
    </div>
    <div class="tile is-ancestor">
      <draggable class="tags are-large tile players-tile" v-model="game_sessions" group="players" key="original">
        <div :class="['tag', session.host ? 'is-info' : 'is-dark', session.invitation_accepted ? '' : 'is-light']" v-for="session in game_sessions" :key="session.id">
          {{session.player_name}}{{ session.host ? ' (host)' : ''}}
        </div>
      </draggable>
      <div v-if="currentGame.teams.length > 1" class="tile is-vertical is-parent">
        <div v-for="(team, index) in sortedTeams" :key="team.id" class="box tile is-child">
          <b-field label="Team" horizontal>
            <input class="input" placeholder="Team Name" type="string" v-model="team.name" @change="gameUpdate"></input>
          </b-field>
          <draggable v-model="team.game_sessions" class="tags are-large team-box" group="players" @change="gameUpdate">
            <div v-for="session in team.game_sessions" :class="['tag', session.host ? 'is-info' : 'is-dark', session.invitation_accepted ? '' : 'is-light']" :key="session.id">
              {{session.player_name}}{{ session.host ? ' (host)' : ''}}
            </div>
          </draggable>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import draggable from 'vuedraggable'
import gameAxios from '../axios/axios_game_update.js';

export default {
	props: {
    game: {
      required: true,
      type: Object
    },
    websocket: {
      type: Object,
      required: true
    },
    currentHost: {
      type: Boolean,
      required: true
    },
    gameSession: {
      type: Object
    }
  },
  components: {
    draggable,
  },
  data: function () {
    return {
      currentGame: {
        team_mode: false,
        teams: []
      },
      game_sessions: [],
      teams: [],
      teamNumbers: null,
      
    }
  },
  computed: {
    sortedTeams: function() {
      return _.sortBy(this.currentGame.teams, ['created_at'])
    },
    numberOfTeams: function() {
      return this.currentGame.teams.length
    },
    teamsAssigned: function() {
      if(!this.currentGame.team_mode) {
        return true
      } else if(this.currentGame.team_mode && this.game_sessions.length == 0) {
        return true
      } else {
        return false
      }
    },
    allAccepted: function() {
      return _.every(this.currentGame.game_sessions, ['invitation_accepted', true ])
    }
  },
  methods: {
    startGame: function() {
      if(this.teamsAssigned) {
        console.log('starting game')
        gameAxios.put(`${this.currentGame.id}`, { game: { started: true}})
          .then(res => {
            // console.log('game started', res)
            // this.currentGame.teams = res.data            
          })
      } else {
        alert('Cannot start game, not all players are assigned to a team.')
      }
      
    },
    removeTeams: function() {
      if(!this.currentGame.team_mode && this.currentGame.teams.length > 0) {
        var changeTeamMode = confirm('Are you sure you want to delete teams?')
        console.log('change team mode to', this.currentGame.team_mode)
        if(changeTeamMode) {
          gameAxios.put(`${this.currentGame.id}`, { game: { team_mode: this.currentGame.team_mode }}).then( res => {
            this.currentGame = res.data
            this.setTeam(res)
          })
        } else {
          this.currentGame.team_mode = true
          console.log('cancelled team delete')
        }
      }
    },
    createTeams: function() {
      // console.log("create teams", this.teamNumbers)
      gameAxios.put(`${this.currentGame.id}`, { game: {team_mode: this.currentGame.team_mode}, team: { numbers: Number(this.teamNumbers) }})
      .then(res => {
        // console.log('team created', res)
        // this.currentGame.teams = res.data
        this.currentGame = res.data
        this.setTeam(res)
      })
    },
    setTeam: function(res) {
      if(res.data.team_mode) {
          this.teamNumbers = res.data.teams.length
        }
    },
    gameUpdate: function() {
      this.currentGame.teams.forEach(team => {
        var game_session_ids = team.game_sessions.map(session => {
          return session.id
        })
        team['game_session_ids'] = game_session_ids
      })

      // console.log('send update', this.currentGame.teams)

      gameAxios.put(`${this.currentGame.id}`, {game: { teams_attributes: this.currentGame.teams}})
        .then(res => {
          // console.log('game setup', res)
        })
    },
    createSetup: function() {
      gameAxios.put(`${this.currentGame.id}`, {game: {}})
      .then(res => {
        // console.log('game started', res)
      })
    } 
  },
  created () {
    // console.log('where is my game', this.game)
    this.currentGame = this.game
    this.game_sessions = this.currentGame.game_sessions.filter(session => {
              return session.team_id == null
            })
    if(this.currentGame.team_mode) {
      this.teamNumbers = this.currentGame.teams.length
    }
    // this.currentGame.teams = this.currentGame.teams
    // this.websocket = this.$cable.useGlobalConnection(this.$store.state.token)
    
    this.subscription = this.websocket.subscriptions.create({
      channel: 'GameSessionsChannel', game: this.currentGame.id }, {
        connected: () => console.log('Connected to Game Session', this.currentGame.id),
        received: (data) => {
          // console.log('received game session', data)
          this.game_sessions.push(data)
        }
    })

    this.subscription = this.websocket.subscriptions.create({
      channel: 'GamesChannel', game: this.game.id }, {
        connected: () => console.log('Connected to Game Channel', this.game.id),
        received: (data) => {
          // console.log('received game', data)
          // if(data.teams != null) {
          //   this.currentGame.teams = data.teams
          // }
          
          if(data.game_sessions != null) {
            this.game_sessions = data.game_sessions
          }

          this.currentGame = JSON.parse(data.game)
          
          // this.currentGame.teams.forEach(team => { team["game_sessions"] = []})
        }
    })
    

  }
}
</script>

<style scoped>

.team-box {
  min-height: 250px;
  align-content: flex-start;
}

.players-tile {
  align-content: center;
}

.is-dark.is-light {
  background-color: grey !important;
}
</style>

<template>
  <div class="columns is-multiline is-mobile">
    <div class="column is-full has-text-centered">
  	 <game-header :game="game" :game-image="gameImage" :image-size="'100px'"></game-header>
      <span class="title is-4">Waiting Room{{ currentGame.started ? ': this game has started' : ''}}</span>
    </div>
    <div class="column is-full">
      <div class="columns">
        <div class="field column is-half" v-if="currentHost">
          <div class="field">
            <b-switch v-model="currentGame.team_mode" :disabled="!currentHost" @input="removeTeams" type="is-dark">
                turn on team mode
            </b-switch>
          </div>
          
          <b-field label="How many teams" v-if="currentGame.team_mode && currentHost">
            <b-input placeholder="Number of teams" type="number" v-model="teamNumbers"></b-input>
            <p class="control">
                <b-button class="button is-dark" @click='createTeams' :disabled="!currentHost">Create</b-button>
            </p>
          </b-field>
          <div v-if="teamsCreated">Go ahead and drag players into your desired teams.</div>
        </div>
        <div v-else-if="currentGame.team_mode && !currentHost" class="column is-half">
          Number of teams: {{numberOfTeams}}
          <div v-if="teamsCreated">Go ahead and drag players into your desired teams.</div>
        </div>

        <div class="column is-half">
          <b-button type="is-dark" @click="startGame" v-if="currentHost && !currentGame.started" :disabled="!allAccepted && teamsAssigned">Start Game</b-button>
        </div>
      </div>
    </div>
    
    <div class="column is-full">
      <div class="tile is-ancestor">
        <div class="tile is-parent">
          <div class="tile is-child box team-outline">
          <div class=""><b>Players</b></div><br />
          <draggable class="tags are-large box players-tile" v-model="gameSessions" group="players" key="original">
            
            <player v-for="session in gameSessions" dragger :game-session="session" :key="session.id" :current-host="currentHost" class=""></player>
          </draggable></div>
        </div>
        <div v-if="currentGame.teams.length > 1" class="tile is-parent is-vertical">
          <div v-for="(team, index) in sortedTeams" :key="team.id" class="box team-outline tile is-child">
            <b-field label="Team" horizontal>
              <input class="input" placeholder="anyone can enter a team name" type="string" v-model="team.name" @change="gameUpdate"></input>
            </b-field>
            <draggable v-model="team.game_sessions" class="tags are-large team-box" group="players" @change="gameUpdate" :key="'teamBox' + team.id">
              <player v-for="session in team.game_sessions" dragger :game-session="session" :key="session.id" :current-host="currentHost"></player>
            </draggable>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import draggable from 'vuedraggable'
import gameAxios from '../axios/axios_game_update.js';
import player from './player';
import gameHeader from './game_header';
import fishbowlImage from '../assets/fish-bowl-logo.png'

export default {
	props: {
    game: {
      required: true,
      type: Object
    },
    currentHost: {
      type: Boolean,
      required: true
    }
  },
  components: {
    draggable, player, gameHeader
  },
  data: function () {
    return {
      teams: [],
      teamNumbers: null,
      currentGame: {},
      gameImage: fishbowlImage
    }
  },
  computed: {
    gameSessions: {
      get: function() { 
        return this.currentGame.game_sessions.filter(session => {
              return session.team_id == null
            })
      },
      set: function(val) {
        this.currentGame.game_sessions = val
      }
    },
    sortedTeams: function() {
      return _.sortBy(this.currentGame.teams, ['created_at'])
    },
    numberOfTeams: function() {
      return this.currentGame.teams.length
    },
    teamsAssigned: function() {
      if(!this.currentGame.team_mode) {
        return true
      } else if(this.currentGame.team_mode && this.gameSessions.length == 0) {
        return true
      } else {
        return false
      }
    },
    allAccepted: function() {
      return _.every(this.currentGame.game_sessions, ['invitation_accepted', true ])
    },
    teamsCreated: function() {
      return this.currentGame.teams.length > 0
    }
  },
  watch: {
    game: function(newVal, oldVal) {
      console.log('game update waiting', newVal)
      this.currentGame = newVal
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
      if(this.currentGame.team_mode == false && this.currentGame.teams.length > 0) {
        var changeTeamMode = confirm('Are you sure you want to delete teams?')
        console.log('change team mode to', this.currentGame.team_mode)
        if(changeTeamMode) {
          gameAxios.put(`${this.currentGame.id}`, { game: { team_mode: this.currentGame.team_mode }}).then( res => {
            console.log('teams deleted')
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
        } else {
          this.teamNumbers = null
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

    if(this.currentGame.team_mode) {
      this.teamNumbers = this.currentGame.teams.length
    }
    

  }
}
</script>

<style scoped>
.team-outline {
  border-radius: 15px;
  border: 1px solid #636363;
}
.team-box {
  min-height: 150px;
  align-content: flex-start;
}

.players-tile {
  align-content: center;
  height: 75%;

}
</style>

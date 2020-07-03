import Vue from 'vue';
import Vuex from 'vuex';
import VueJwtDecode from 'vue-jwt-decode'
import axios from 'axios';
import gameAxios from '../axios/axios_game_update.js';
import fishbowlImage from '../assets/fish-bowl-glow.png';
import fishbowlLogo from '../assets/fish-bowl-logo.png';
import fishbowlGlow from '../assets/fish-bowl-glow.png';
import ghostImage from '../assets/smileys-filled.png';
import ghostLogo from '../assets/smileys-logo.png';
import ghostGlow from '../assets/smileys-filled.png';
import winkImage from '../assets/wink-filled.png';
import winkLogo from '../assets/wink-logo.png';
import winkGlow from '../assets/wink-glow.png';

Vue.use(Vuex);

export const store = new Vuex.Store({
	state: {
		token: localStorage.getItem('auth_token'),
		gameSession: localStorage.getItem('game_session'),
		games: [
			{name: 'Fishbowl', description: "This is a fun group game. Teams will guess the same clues through rounds of giving descriptions (Taboo), acting out (Charades), and single describing word (Password). ", image: fishbowlImage, logo: fishbowlLogo, glow: fishbowlGlow},
      {name: 'Ghost', description: "This is a game where players take turns adding letters to a growing word fragment. The first to complete a valid word looses the round.", image: ghostImage, logo: ghostLogo, glow: ghostGlow},
     	{name: 'WinkMurder', description: "Group game where designated murderer(s) is/are unknown to the group, and the murderer(s) will kill by winking at the players", image: winkImage, logo: winkLogo, glow: winkGlow}
     ],
	},
	getters: {
		currentUser: (state, getters) => {
			if(getters.tokenValid) {
				return VueJwtDecode.decode(state.token)
			} else {
				return null
			}
		},
		getGames: (state, getters) => {
			return state.games
		},
		gameInfo: (state) => (gameName) => {
			return _.find(state.games, {name: gameName})
		},
		authenticated: (state, getters) => {
			if(state.token != null && getters.tokenValid) {
				return true
			} else {
				return false
			}
		},
		tokenValid: state => {
			if(state.token != null) {
				const payload = VueJwtDecode.decode(state.token)
				const expiry = payload.exp
				var d = new Date();
				var now = d.getTime() /1000;
				var expDate = new Date(expiry)
				// console.log(expiry)
				// console.log(expDate)

				return now < expiry
			} else {
				return false
			}
		},
		getToken: state => {
			return state.token
		},
		gameSession: state => {
			return JSON.parse(state.gameSession)
		}
	},
	mutations: {
		setToken (state, payload) {
			state.token = payload
		},
		resetToken (state, payload) {
			state.token = localStorage.getItem('auth_token')
		},
		setGameSession (state, payload) {
			state.gameSession = localStorage.getItem('game_session')
		}
	},
	actions: {
		authenticateUser({commit, dispatch, state}, formData) {
			return new Promise((resolve, reject) => { 
				axios.post('/api/user_token', {auth: formData })
		        .then( res => {
		          localStorage.setItem('auth_token', res.data.jwt)
		          // console.log(res)
		          // console.log(res.data.jwt)
		          commit('setToken', res.data.jwt);
		          // console.log(state.token)
		          resolve(res)
		        })
		        .catch( error => {
		          console.log(error)
		          localStorage.removeItem('auth_token');
		          commit('setToken', null);
		          reject(error)
		       })
			})
		},
		// not being used at this moment as it may not be necessary to be put in store
		registerUser({commit, dispatch, state}, formData) {
			return new Promise((resolve, reject) => {
		      axios.post('/api/users', {user: formData })
		        .then( res => {
		        	console.log(res)
		          localStorage.setItem('auth_token', res.data.body.token)
		          commit('setToken', res.data.body.token)
		          
		          resolve(res)	
		        })
		        .catch( error => {
		          console.log(error)
		          // localStorage.removeItem('auth_token');
		          // commit('setToken', null);
		          reject(error)
		        })
			})
		},
		destroyToken({commit, dispatch, state}) {
			return new Promise((resolve, reject) => {
				localStorage.removeItem('auth_token')
				commit('resetToken')

				resolve()
			})
		},
		reloadGameSession({commit, dispatch, state}, payload) {
			return new Promise((resolve, reject) => {
				axios.get(`/api/game_sessions?search=${payload.player.value}&game_id=${payload.gameId.value}${payload.user}`)
        .then(res => {
          console.log('rejoin', res.data)
          dispatch('resetGameSession', res.data)
          resolve(res)
        }).catch(error => {
        	console.log(error)
        	reject(error)
        })
			})
		},
		resetGameSession({commit, dispatch, state}, gameSession) {
			localStorage.setItem('game_session', JSON.stringify(gameSession))
			commit('setGameSession')
		},
		clearGameSession({commit, dispatch, state}) {
			localStorage.removeItem('game_session')
			commit('setGameSession')
		},
		updateGame({commit, dispatch, state}, game) {
			console.log('update payload', game)
			return new Promise((resolve, reject) => {
				gameAxios.put(`${game.id}`, {game: game})
          .then(res => {
            console.log('game updated', res)
            resolve(res)
          })
          .catch(error => {
          	console.log('game update error', error)
          	reject(error)
          })
			})
		}
	}
})
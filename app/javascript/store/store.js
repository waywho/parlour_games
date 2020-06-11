import Vue from 'vue';
import Vuex from 'vuex';
import VueJwtDecode from 'vue-jwt-decode'
import axios from 'axios';
import gameAxios from '../axios/axios_game_update.js';

Vue.use(Vuex);

export const store = new Vuex.Store({
	state: {
		token: localStorage.getItem('auth_token'),
		gameSession: localStorage.getItem('game_session')
	},
	getters: {
		currentUser: (state, getters) => {
			if(getters.tokenValid) {
				return VueJwtDecode.decode(state.token)
			} else {
				return null
			}
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
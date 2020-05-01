import Vue from 'vue';
import Vuex from 'vuex';
import VueJwtDecode from 'vue-jwt-decode'
import axios from 'axios'

Vue.use(Vuex);

export const store = new Vuex.Store({
	state: {
		token: localStorage.getItem('auth_token')
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
				console.log(expiry)
				console.log(expDate)

				return now < expiry
			} else {
				return false
			}
		}
	},
	mutations: {
		setToken (state, payload) {
			state.token = payload
		}
	},
	actions: {
		authenticateUser({commit, dispatch, state}, formData) {
			return new Promise((resolve, reject) => { 
				axios.post('/user_token', {auth: formData })
		        .then( res => {
		          localStorage.setItem('auth_token', res.data.jwt)
		          // console.log(res)
		          // console.log(res.data.jwt)
		          commit('setToken', res.data.jwt);
		          resolve(res)
		        })
		        .catch( error => {
		          console.log(error.response)
		          localStorage.removeItem('auth_token');
		          commit('setToken', null);
		          reject(error)
		       })
			})
		},
		// not being used at this moment as it may not be necessary to be put in store
		registerUser({commit, dispatch, state}, formData) {
			return new Promise((resolve, reject) => {
		      axios.post('/sign_up', {user: formData })
		        .then( res => {
		          localStorage.setItem('auth_token', res.data.body.token)
		          commit('setToken', res.data.body.token)
		          // console.log(res)
		          resolve(res)	
		        })
		        .catch( error => {
		          console.log(error.response)
		          // localStorage.removeItem('auth_token');
		          // commit('setToken', null);
		          reject(error)
		        })
			})
		}
	}
})
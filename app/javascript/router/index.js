import Vue from 'vue'
import VueRouter from 'vue-router'
import Registration from '../components/registration'
import SignIn from '../components/sign_in'
import { store } from '../store/store'
import landingPage from '../components/landing_page'
import Chatrooms from '../components/chatrooms'
import videoChats from '../components/video_chats'
import Games from '../components/games'
import Game from '../components/game'
import MyGames from '../components/my_games'
import JoinGame from '../components/join_game'

const ifNotAuthenticated = (to, from, next) => {
	if (!store.getters.authenticated) {
		next('/sign_in')
		return
	}
	next()
}

const ifAuthenticated = (to, from, next) => {
	if (store.getters.authenticated) {
		next('/chat')
		return
	} 
	next('/sign_in')
}

const notJoinedGame = (to, from, next) => {
	console.log('destination', to)
	// console.log(store.getters.gameSession.game_id)
	if(store.getters.gameSession == null || store.getters.gameSession == undefined) {
		next(`/join_game/${to.params.game_id}`)
	} else if(to.params.game_id == store.getters.gameSession.game_id) {
		next()
	} else {
		next(`/join_game/${to.params.game_id}`)
	}
}

Vue.use(VueRouter)
const router = new VueRouter({
	mode: 'history',
	routes: [
		{ path: '/', component: landingPage },
		{ path: '/chats', name: 'chats', component: Chatrooms, beforeEnter: ifNotAuthenticated },
		{ path: '/video_chats', component: videoChats, beforeEnter: ifNotAuthenticated },
		{ path: '/games', component: Games, beforeEnter: ifNotAuthenticated },
		{ path: '/my_games', component: MyGames, beforeEnter: ifNotAuthenticated},
		{ path: '/games/:gameComponent/:game_id', name: 'game', component: Game, props: true, beforeEnter: notJoinedGame },
		{ path: '/join_game', name: 'join_game_noid', component: JoinGame },
		{ path: '/join_game/:game_id', name: 'join_game', component: JoinGame, props: true },
		// { path: '/games/fish_bowl', component: FishBowl, beforeEnter: ifNotAuthenticated },
		{ path: '/sign_up', name: 'registraton', component: Registration},
		{ path: '/sign_in', name: 'signIn', component: SignIn }, 
	]
})

export default router
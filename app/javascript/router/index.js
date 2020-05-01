import Vue from 'vue'
import VueRouter from 'vue-router'
import Registration from '../components/registration'
import SignIn from '../components/sign_in'
import { store } from '../store/store'
import landingPage from '../components/landing_page'
import Chatrooms from '../components/chatrooms'
import videoChats from '../components/video_chats'

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

Vue.use(VueRouter)
const router = new VueRouter({
	mode: 'history',
	routes: [
		{ path: '/', component: landingPage },
		{ path: '/chat', component: Chatrooms, beforeEnter: ifNotAuthenticated },
		{ path: '/video_chats', component: videoChats, beforeEnter: ifNotAuthenticated },
		{ path: '/sign_up', name: 'registraton', component: Registration, beforeEnter: ifNotAuthenticated},
		{ path: '/sign_in', name: 'signIn', component: SignIn }, 
	]
})

export default router
/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

// Rails.start()
ActiveStorage.start()

console.log('Hello World from Webpacker')

import Vue from 'vue'
import App from '../app.vue'
// import '../assets/main.css'
// import "../assets/animate.min.css";
import VueChatScroll from 'vue-chat-scroll'
import router from '../router'
import { store } from '../store/store'
import VueActionCable from 'vue-action-cable'
// import WebRTC from '@argueta10/vue-webrtc'
import vueMoment from 'vue-moment'
import moment from 'moment'
import _ from 'lodash'

// import VueDraggable from 'vue-draggable'
import { library } from '@fortawesome/fontawesome-svg-core'
import { fas } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import Buefy from 'buefy'
import '../styles/global.scss'
import Fitty from 'vue-fitty' 

export const bus = new Vue({})
	
document.addEventListener('DOMContentLoaded', () => {
	Vue.use(Fitty)
	library.add(fas)
	Vue.component('font-awesome-icon', FontAwesomeIcon);
	Vue.use(Buefy, {
		defaultFieldLabelPosition: 'on-border',
		defaultIconComponent: 'font-awesome-icon',
		defaultIconPack: 'fas',
    defaultContainerElement: '#content'
	})

	Vue.use(VueChatScroll)

	// Vue.use(WebRTC)
	
	Vue.use(require('vue-moment'))

	Vue.use('_')

	// Vue.use(VueDraggable)
	Vue.filter('sumScore', function(object) {
		return Object.values(object).reduce((a, b) => a + b)
	})
	Vue.filter('human-date', function(value) {
		var now = Date.now();
		var createdDate = new Date(value)
		var timeDelta = now - createdDate
		if(timeDelta > 86400000) {
			return moment(value).format('hA, L')
		} else {
			return moment(value).fromNow()
		}
	})

	Vue.filter('capitalize', function (value) {
	  if (!value) return ''
	  value = value.toString()
	  return value.charAt(0).toUpperCase() + value.slice(1)
	})

	Vue.filter('camel-to-space', function (value) {
	  if (value !== null && value !== undefined) {
	    value = value.replace(/([A-Z])/g, " $1");
	    return value.charAt(0).toUpperCase() + value.slice(1)
	  } else {
	    return ''
	  }
	})

	Vue.filter('camelToUnderscore', function (value) {
	  if (value !== null && value !== undefined) {
	    value = value.replace(/([A-Z])/g, "_$1");
	    value = value.replace(/^[_]/, "");
	    return value.toLowerCase()
	  } else {
	    return ''
	  }
	})

	Vue.filter('camelToKabab', function (value) {
	  if (value !== null && value !== undefined) {
	    value = value.replace(/([A-Z])/g, "-$1");
	    value = value.replace(/^[-]/, "");
	    return value.toLowerCase()
	  } else {
	    return ''
	  }
	})

	Vue.filter('kabab-to-space', function (value) {
	  if (value !== null && value !== undefined) {
	  	// value = value.replace(/\_/g, " ")
	    value = value.split("_");
	    const value_array = value.map(function(word) {
	    	return word.charAt(0).toUpperCase() + word.slice(1)
	    })
	    value = value_array.join(" ")
	    return value.charAt(0).toUpperCase() + value.slice(1)
	  } else {
	    return ''
	  }
	})

	
	// wss://parlour-games-who.herokuapp.com/
	// ws://localhost:5000/

	let websocketConnection = "ws://localhost:5000/"// process.env.WEBSOCKET_PATH

	Vue.use(VueActionCable, {
		connectionUrl: "/cable",
	})


	const app = new Vue({
	 render: h => h(App),
	 router: router,
	 store: store
	}).$mount()

	const appDOM = document.getElementById('spa')

	if (appDOM) {
		appDOM.appendChild(app.$el)
		console.log(app)
	}


	// console.log(process.env)
})

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

console.log('Hello World from Webpacker')

import Vue from 'vue'
import App from '../app.vue'
// import '../assets/main.css'
// import "../assets/animate.min.css";
// import router from '../router'
// import { store } from '../store/store'
import Buefy from 'buefy'
import 'buefy/dist/buefy.css'

document.addEventListener('DOMContentLoaded', () => {
	Vue.use(Buefy, {
		defaultFieldLabelPosition: 'on-border'
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
	
	const app = new Vue({
	 render: h => h(App),
	 // router: router,
	 // store: store
	}).$mount()
	document.body.appendChild(app.$el)



	console.log(app)
})
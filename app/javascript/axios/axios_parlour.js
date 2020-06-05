import axios from 'axios'
import { store } from '../store/store'

const instance = axios.create({
	baseURL: '/api'
})

instance.interceptors.request.use(
	function(config) {
		const token = store.state.token;
		if(token) {
			config.headers.Authorization = `Bearer ${token}`;
			return config;
		}
	},
	function(error) {
		return Promise.reject (error);
	}

);

// instance.defaults.headers.common['SOMETHING'] = 'something'

export default instance
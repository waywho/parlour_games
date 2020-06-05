import axios from 'axios'
import { store } from '../store/store'

const instance = axios.create({
	baseURL: '/api/games/'
})

export default instance
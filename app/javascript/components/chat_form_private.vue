<template>
  <chat-form :chatroom="chatroom" v-on:start-chat="$emit('start-chat', chatroom)" v-on:close-modal="$parent.close()">
    <header slot="form-header" class="modal-card-title">New Private Chat</header>
    <div slot="form-fields">
       <p class="content"><b>Selected users:</b> <span class="tag is-medium is-outlined is-success" v-for="user in selectedUsers">{{ user.name }}<button class="delete" @click="removeUser(user)"></button></span></p>
         <b-field label="Find a User">
            <b-autocomplete
                v-model="search"
                placeholder="e.g. Anne"
                :keep-first="false"
                :open-on-focus="true"
                :data="searchResults"
                field="name"
                @select="option => selectUser(option)">
            </b-autocomplete>
        </b-field>
    </div>
  </chat-form>
</template>

<script>
import chatForm from './chat_form';
import axios from 'axios';

export default {
  components: {
    'chat-form': chatForm
  },
  props: ['users'],
  data: function () {
    return {
      selectedUsers: [],
      search: "",
      chatroom: {
        user_ids: [],
        topic: "",
        public: false
      },
      active: ''
    }
  },
  computed: {
    searchResults: function() {
      return this.users.filter((user) => {
        return user.name.toString().toLowerCase().indexOf(this.search.toLowerCase()) >= 0
      })
    }
  },
  methods: {
    userSearch: function() {
      axios({
        method: 'get',
        url: '/users',
        params: {
          search: this.name
        },
        paramsSerializer: function (params) {
          return qs.stringify(params, {arrayFormat: 'brackets'})
        }
      }).then(res => {
        console.log('users', res.data)
        this.users = res.data
      })
    },
    openDropdown() {
      this.active = 'is-active'
    },
    keyArrows(direction){
      const sum = direction === 'down' ? 1 : -1
      if(this.active === 'is-active') {
        let index = this.searchResults.indexOf()
      } else {
        this.active = "is-active"
      }
    },
    selectUser: function(user) {
      if(user === null || user === undefined) {
        return }
      this.selectedUsers.push(user)
      this.search = ""
      var nameArray = []
      
      var idArray = []
      idArray.push(this.$store.getters.currentUser.sub)
      this.selectedUsers.forEach((user) => {
        nameArray.push(user.name)
        idArray.push(user.id)
      })
      nameArray.push(this.$store.getters.currentUser.name)
      this.chatroom.topic = nameArray.join(", ")
      this.chatroom.user_ids = idArray
      this.active = ""
    },
    removeUser: function(user) {
      var foundIndex = this.selectedUsers.indexOf(user)
      if(foundIndex > -1) {
        this.selectedUsers.splice(foundIndex, 1);
      }
    }
  }
}
</script>
<style scoped>
.dropdown-menu {
  z-index: 99 !important;
}
</style>
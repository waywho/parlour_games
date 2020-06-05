<template>
  <chat-form :chatroom="chatroom" v-on:submit="$emit('start-chat', chatroom)" v-on:close-modal="$parent.close()">
    <header slot="form-header" class="modal-card-title">New Private Chat</header>
    <div slot="form-fields">
       <p class="content"><b>Selected users:</b> <span class="tag is-medium is-outlined is-success" v-for="user in selectedUsers">{{ user.name }}<button class="delete" @click="$refs.userSelectInput.removeUser(user)"></button></span></p>
         <user-select-input ref="userSelectInput" v-on:users-select="selectUsers" v-on:users-remove="selectUsers"></user-select-input>
    </div>
    <span slot="submit-button">Start Chat</span>
  </chat-form>
</template>

<script>
import chatForm from './chat_form';
import userSelect from './user_select'

export default {
  components: {
    'chat-form': chatForm,
    'user-select-input': userSelect
  },
  data: function () {
    return {
      selectedUsers: [],
      search: "",
      chatroom: {
        user_ids: [],
        topic: "",
        public: false
      }
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
    selectUsers: function(selectedUsers) {
      this.selectedUsers = selectedUsers
      if(selectedUsers === null || selectedUsers === undefined || selectedUsers.length === 0) {
        this.chatroom.user_ids = []
        this.chatroom.topic = ""
        return
      }

      
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

    }
  }
}
</script>
<style scoped>
.dropdown-menu {
  z-index: 99 !important;
}
</style>
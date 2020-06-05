<template>
  <chat-form v-on:submit="$emit('send-invite', userIds)" v-on:close-modal="$parent.close()">
    <header slot="form-header" class="modal-card-title">Invite Users to {{game_name | camel-to-space }}</header>
    <div slot="form-fields">
       <p class="content"><b>Select users to invite:</b> <span class="tag is-medium is-outlined is-success" v-for="user in selectedUsers">{{ user.name }}<button class="delete" @click="$refs.userSelectInput.removeUser(user)"></button></span></p>
        <user-select-input ref="userSelectInput" v-on:users-select="selectUsers" v-on:users-remove="selectUsers"></user-select-input>
    </div>
    <span slot="submit-button">Invite</span>
    <b-button slot="additional-buttons" type="is-default" @click="$emit('no-invite', userIds)">Invite Later</b-button>
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
  props: ['game_name'],
  data: function () {
    return {
      selectedUsers: [],
      userIds: [],
      active: ''
    }
  },
  methods: {
    selectUsers: function(selectedUsers) {
      this.selectedUsers = selectedUsers
      if(selectedUsers === null || selectedUsers === undefined || selectedUsers.length === 0) {
        this.userIds = []
        return
      }
      var idArray = []
      this.selectedUsers.forEach((user) => {
        idArray.push(user.id)
      })

      this.userIds = idArray
    }
   
  }
}
</script>
<style scoped>
.dropdown-menu {
  z-index: 99 !important;
}
</style>
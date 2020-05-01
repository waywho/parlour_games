<template>
  <chat-form :chatroom="chatroom" v-on:start-chat="$emit('start-chat', chatroom)" v-on:close-modal="$parent.close()">
    <header slot="form-header" class="modal-card-title">New Chat</header>
    <div slot="form-fields">
      <b-field label="Topic">
        <b-input v-model="chatroom.topic"></b-input>
      </b-field>
      <div class="field">
         <b-switch v-model="chatroom.public"
          type="is-primary">
              {{ chatroom.public ? 'public' : 'private' }}
          </b-switch>
      </div>
    </div>
  </chat-form>
</template>

<script>
import chatForm from './chat_form';

export default {
  components: {
    'chat-form': chatForm
  },
  data: function () {
    return {
       chatroom: {
        topic: null,
        public: true,
        user_ids: []
      }
    }
  },
  created() {
    this.chatroom.user_ids.push(this.$store.getters.currentUser.sub)
  }
}
</script>

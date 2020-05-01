<template>
  <div class="tile is-parent is-vertical is-9 chat-tile">
    <div class="tile is-child chat-box">

      <div class="tile title-tile">
        <h2 class="title is-4 ">{{ chatTitle }}</h2>
        <b-field v-if="currentChatroom && currentChatroom.public == true" grouped position="is-right" class=""><!-- Label left empty for spacing -->
          <b-button type="is-danger is-outlined is-rounded is-small" @click="$emit('leave-chat', currentChatroom)">leave</b-button>
        </b-field>
      </div>
      <div class="messages" v-chat-scroll>
        <div class="message-piece tile" v-for="message in messages">
          <span><b>{{message.user.name}}:</b> {{ message.content }}</span>
          <span class="is-size-7 has-text-grey-light message-date">{{message.created_at}}</span>
        </div>
      </div>
    </div>
    <div class="tile is-child">
      <form @submit.prevent="sendMessage">
        <b-field>
          <b-input type="textarea"
              placeholder="enter text"
              v-model="message">
          </b-input>
        </b-field>
        <b-field grouped position="is-right"><!-- Label left empty for spacing -->
          <b-button type="is-primary" native-type="submit">chat</b-button>
        </b-field>
      </form>
    </div>
    
  </div>
</template>

<script>
import axios from 'axios';

export default {
  props: ['userId', 'currentChatroom', 'chatName', 'messages'],
  data: function () {
    return {
      message: ""
    }
  },
  computed: {
    chatTitle: function() {
      if(this.currentChatroom !== null && this.currentChatroom !== undefined) {
        return this.currentChatroom.topic
      } else {
        return null
      }
      
    }
  },
  methods: {
    sendMessage: function() {
      // this.$cable.perform({
      //   channel: 'MessagesChannel',
      //   action: 'send_message',
      //   data: {
      //     content: this.message
      //   }
      // })
      axios.post('/messages',  {message: {chatroom_id: this.currentChatroom.id, content: this.message}}).then(res => {
          this.message = null
          console.log('sent message', res)
        })
    }
  }
}
</script>

<style scoped>
.title-tile {
  justify-content: space-between;
}
.chat-tile {
  min-height: 95vh;
  height: 95vh;
}

.messages {
  min-height: 90%;
  height: 90%;
  overflow: scroll;
}

.chat-box {
  min-height: 70%;
  height: 70%;
  max-height: 70%;
}

.message-piece {
  margin-bottom: 10px;
  justify-content: space-between;
}

.message-piece:hover .message-date {
  color: hsl(0, 0%, 48%) !important;
}
</style>
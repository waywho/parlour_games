<template>
  <div class="tile is-vertical chat-tile">
    <div class="tile is-vertical chat-tile-inner">
      <div v-if="withTitle" class="tile is-parent is-space-between">
        <span class="title tile is-10 is-child">{{ chatTitle }}</span>
        <!-- <b-field  grouped position="is-right" class="">Label left empty for spacing -->
        <div class="tile is-child">
          <b-button v-if="currentChatroom && currentChatroom.public == true" type="is-danger is-outlined is-rounded is-small" @click="$emit('leave-chat', currentChatroom)" class="is-pulled-right">leave</b-button>
        </div>
        <!-- </b-field> -->
      </div>
      <div class="title-frame" v-else>
        <b>Chats / Guesses</b>
      </div>      
      <div class="tile is-parent messages is-vertical" v-chat-scroll>
        <div class="message-piece" v-for="message in chatroomMessages">
          <span><b>{{message.speakerable.name}}:</b> {{ message.content }}</span>
          <span class="is-size-7 has-text-grey-light message-date">{{message.created_at | human-date }}</span>
        </div>
      </div>
    </div>
    <div :class="['tile', textInput ? 'chat-box-text' : 'chat-box', 'is-parent']" v-if="withInput">
      <div class="tile is-child">
        <form @submit.prevent="sendMessage" >
        
          <span v-if="textInput">
            <b-field>
              <b-input type="textarea"
                placeholder="enter text"
                v-model="currentMessage"
                v-on:keyup.enter="sendMessage"
                rows="3"
              >
              </b-input>
            </b-field>
            <b-field grouped position="is-right"><!-- Label left empty for spacing -->
              <b-button type="is-dark" native-type="submit">chat</b-button>
            </b-field>
          </span>

          <b-field v-else>
            <b-input placeholder="enter text" v-model="currentMessage" expanded></b-input>
            <p class="control">
                <b-button class="button is-dark" v-on:keyup.enter="sendMessage" native-type="submit">chat</b-button>
            </p>
          </b-field>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  props: {
    chatroomId: {
      type: Number,
      required: true,
    },
    textInput: {
      type: Boolean,
      required: false,
      default: true
    },
    withTitle: {
      type: Boolean,
      required: false,
      default: true
    },
    gameMode: {
      type: Boolean,
      required: false,
      default: false
    },
    withInput: {
      type: Boolean,
      required: false,
      default: true
    },
    message: {
      type: String,
      required: false
    }
  },
  data: function () {
    return {
      chatroomMessages: [],
      currentChatroom: {},
      currentMessage: ""
    }
  },
  computed: {
    chatTitle () {
      return this.currentChatroom.topic
    },
    speaker () {
      if(this.gameMode) {
        return this.$store.getters.getSession
      } else {
        return this.$store.getters.currentUser
      }
    }
  },
  watch: {
    message(newVal, oldVal) {
      this.currentMessage = newVal
    }
  },
  methods: {
    sendMessage: function() {
      // TODO clean up the message sending by using the actual value than v-modal
      axios.post('/api/messages',  {
        message: {
          chatroom_id: this.chatroomId, 
          content: this.currentMessage, 
          speakerable_id: this.speaker.id, 
          speakerable_type: this.speaker.class_name
        }
      }).then(res => {
          this.currentMessage = null
          console.log('sent message', res)
        }).catch( error => {
          console.log(error)
        })
    },
    getMessages: function(chatroom_id) {
      axios({
        method: 'get',
        url:`/api/chatrooms/${chatroom_id}`
      }).then(res => {
        // console.log('current', res)
        if(res.data !== null) {
          this.currentChatroom = res.data
          this.chatroomMessages = _.sortBy(res.data.messages, ["created_at"])
        }
      })
    }
  },
  created() {
    this.getMessages(this.chatroomId)
    this.websocket = this.$cable.useGlobalConnection(this.$store.state.token)
    this.subscription = this.websocket.subscriptions.create({
      channel: 'MessagesChannel', chatroom: this.chatroomId }, {
        connected: () => console.log(`Connected to Message chatroom ${this.chatroomId}` ),
        received: (data) => {
          console.log('received message chat', data)
          this.chatroomMessages.push(data)
          this.$emit('guessing-clue', data.content)
        }
    })
  }
}
</script>

<style scoped>
.title-frame {
  border-bottom: 1px solid grey;
  padding: 0.75rem;
}
.chat-tile {
  /*height: 100%;*/
}

.chat-tile-inner {

}

.messages {
  height: 90%;
  max-height: 90%;
  min-height: 90%;
  overflow: scroll;
}

.chat-box {
  min-height: 16%;
  height: 16%;
  max-height: 16%;
}

.chat-box-text {
  min-height: 25%;
  height: 25%;
  max-height: 25%;
}

.message-piece {
  margin-bottom: 10px;
  justify-content: space-between;
  display: flex;
}

.message-piece:hover .message-date {
  color: hsl(0, 0%, 48%) !important;
}
</style>
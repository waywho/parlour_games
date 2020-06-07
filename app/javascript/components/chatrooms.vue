<template>
  <div class="tile is-ancestor">
    <div class="tile is-3 is-vertical">
      <div class="panel is-dark">
        <p class="panel-heading">Chatrooms</p>
        <div class="panel-block">
          
          <b-field  class="full-input">
            <b-autocomplete
                v-model="search"
                placeholder="search topic..."
                :keep-first="false"
                :open-on-focus="true"
                :data="chatroomSearchResults"
                field="topic"
                expanded
                @input="searchChatrooms"
                @select="option => joinChat(option.id)">
            </b-autocomplete>
          </b-field>
        </div>
        <a :class="['panel-block', chat.new_message ? 'bold-chat' : '']" :id="'chatroom-' + chat.id" v-for="chat in publicChats" @click="joinChat(chat.id)" ref="publicChats">
          #{{ chat.topic }}
        </a>
        <div class="panel-block">
          <b-button type="is-dark" @click="setOpenForm('chat-form-channel')" outlined expanded>
            Create new channel
          </b-button>
        </div>
        <p class="panel-heading">Private Chats</p>
        <div class="panel-block">
          <b-button type="is-dark" @click="setOpenForm('chat-form-private')" outlined expanded>
            Start Private Chat
          </b-button>
        </div>
          <a class="panel-block" :id="'chatroom-' + chat.id" v-for="chat in privateChats" @click="joinChat(chat.id)" ref="privateChats">
            #{{ chat.topic }}
          </a>
      </div>
    </div>

    <chat v-if="chatroomId" :text-input="true" :with-title="true" :chatroom-id="chatroomId" v-on:leave-chat="leaveChat" :messages="messages" :key="chatroomId"></chat>
    <b-modal :active.sync="isComponentModalActive" 
                 has-modal-card
                 trap-focus
                 aria-role="dialog"
                 aria-modal>
      <component :is="currentForm" v-on:start-chat="startChat"></component>
    </b-modal>
  </div>
</template>

<script>
import parlourAxios from '../axios/axios_parlour.js';
import chat from './chat';
import chatFormChannel from './chat_form_channel';
import chatFormPrivate from './chat_form_private';
import qs from 'qs';

export default {
  name: 'chatrooms',
  components: {
    'chat': chat,
    'chat-form-channel': chatFormChannel,
    'chat-form-private': chatFormPrivate,
  },
  data: function () {
    return {
      users: [],
      chatrooms: [],
      messages: [],
      userId: null,
      chatroomId: null,
      currentChatroom: null,
      isComponentModalActive: false,
      search: "",
      currentForm: 'chat-form-channel',
      chatroomSearchResults: []
    }
  },
  computed: {
    privateChats: function () {
      var chats = this.chatrooms.filter(chatroom => {
        return chatroom.public == false
      })
      return _.sortBy(chats, ['updated_at']).slice(0, 5)

    },
    publicChats: function () {
      var chats = this.chatrooms.filter(chatroom => {
        return chatroom.public == true
      })

      return _.sortBy(chats, ['updated_at']).slice(0, 5)
    }
  },
  methods: {
    searchChatrooms() {
      if(this.search.length > 2) {
          parlourAxios({
          method: 'get',
          url: `/chatrooms`,
          params: {
            search: this.search
          },
          paramsSerializer: function (params) {
            return qs.stringify(params, {arrayFormat: 'brackets'})
          }

        }).then(res => {
          // console.log('chatrooms serach', res.data)
          this.chatroomSearchResults = res.data
        })
      }
      
    },
    joinChat(chatroom_id) {
      console.log('join chat')
      if(chatroom_id != null || chatroom_id != undefined) {
        parlourAxios.post(`/chatrooms/${chatroom_id}/join_chat`, {chatroom: {user_id: null}}).then(res => {
          console.log(res)
          this.chatroomId = res.data.id
          // this.getMessages(this.chatroomId, null)
        })
      }
      
    },
    leaveChat(chatroom) {
      parlourAxios.post(`/chatrooms/${chatroom.id}/leave_chat`, {chatroom: {user_id: null}}).then(res => {
          // console.log(res)
          this.chatroomId = null
          this.currentChatroom = null
        })
    },
    startChat: function(chatroom_object) {
      console.log('chat', chatroom_object)

      parlourAxios.post('/chatrooms', {chatroom: chatroom_object}).then(res => {
        console.log('room created', res)
        this.isComponentModalActive = false
      })

    },
    getMessages: function(chatroom_id, user_ids) {
      parlourAxios({
        method: 'get',
        url:`/chatrooms/${chatroom_id}`
      }).then(res => {
        // console.log('current', res)
        if(res.data !== null) {
          this.currentChatroom = res.data
          this.messages = res.data.messages
        }

        var chatNew = this.chatrooms.filter(chat => {
          return chat.id === this.currentChatroom.id
        })

        if(this.chatrooms.length > 0) {
          chatNew[0].new_message = false
        }
      })
    },
    setOpenForm(form_name) {
      this.currentForm = form_name
      this.isComponentModalActive = true
    }
  }, 
  created() {
    // this.$cable.subscribe({
    //   channel: 'ChatroomChannel'
    // })
    console.log('current user', this.$store.getters.currentUser)
    
    parlourAxios({
      method: 'get', 
      url: '/chatrooms',
      params: {
        type: 'my'
      },
      paramsSerializer: function (params) {
          return qs.stringify(params, {arrayFormat: 'brackets'})
        }

      }).then(res => {
        console.log('chatrooms', res.data)
        res.data.forEach(chat => {
          chat["new_message"] = false
        })
        this.chatrooms = res.data
      })


  },
  mounted() {
    this.websocket = this.$cable.useGlobalConnection(this.$store.state.token)

    this.subscription = this.websocket.subscriptions.create({
      channel: 'MessagesChannel' }, {
        connected: () => console.log('Connected to Message'),
        received: (data) => {
          console.log('received message room', data)
          var chatNew = this.chatrooms.filter(chat => {
            return chat.id === data.chatroom_id
          })
          if(chatNew != undefined && chatNew != null) {
            chatNew[0].new_message = true
          }
          
        }
    })
  }
}
</script>

<style scoped >
.bold-chat {
  font-weight: bold;
}

.full-input {
  width: 100% !important;
}

</style>

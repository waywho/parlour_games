<template>
  <div class="tile is-ancestor">
    message: {{message}}
  </div>
</template>

<script>

export default {
  components: {

  },
  data: function () {
    return {
      message: null
    }
  },
  mounted() {
    this.websocket = this.$cable.useGlobalConnection(this.$store.state.token)
    this.subscription = this.websocket.subscriptions.create({
      channel: 'ChatroomsChannel' }, {
        connected: () => console.log('Connected to Chatroom'),
        received: (data) => {
          console.log('received chatroom', data)
          this.message = data
          this.$emit('new-note')
        }
      })

    this.subscription = this.websocket.subscriptions.create({
      channel: 'GameSessionsChannel', game: 'general' }, {
        connected: () => console.log('Connected to GameSessions General'),
        received: (data) => {
          console.log('received game session general', data)
          this.message = data
          this.$emit('new-note')
        }
    })
    this.subscription = this.websocket.subscriptions.create({
      channel: 'MessagesChannel' }, {
        connected: () => console.log('Connected to Messages'),
        received: (data) => {
          console.log('received message2', data)
          this.message = data
          this.$emit('new-note')
        }
    })
  }
}
</script>

<style scoped>

</style>

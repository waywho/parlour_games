<template>
  <form @submit.prevent="$emit('start-chat', chatroom)">
    <div class="modal-card">
      <header class="modal-card-head">
        <slot name="form-header"></slot>
      </header>
      <section class="modal-card-body chatform-content">
        <slot name="form-fields"></slot>
      </section>
      <footer class="modal-card-foot">
        <b-field class="buttons" grouped position="is-right">
          <b-button type="is-outlined" @click="$emit('close-modal')">Cancel</b-button>
          <b-button type="is-primary" native-type="submit">Start Chat</b-button>
        </b-field>
      </footer>
    </div>
  </form>
</template>

<script>

export default {
  props: ['chatroom'],
  data: function () {
    return {
    }
  }
}
</script>

<style scoped>
.modal-card {
  overflow: visible !important;
}

.chatform-content {
  overflow: visible !important;
}
</style>

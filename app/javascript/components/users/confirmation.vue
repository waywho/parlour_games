<template>
  <div>
    <h2 class="title is-2">Confirmation</h2>
    <p>
      Your email has been confirmed. Thank you.
    </p>
    <p>
      <br />
      Happy Playing,
      <br />
      Your game master
    </p>
  </div>
</template>

<script>

export default {
  name: 'user_confirmation',
  data: function () {
    return {
      
    }
  },
  methods: {
    
  },
  mounted () {
    // console.log(formData)
      // this.$store.dispatch('confirmUser', this.$route.query.confirmation_token).then((res) => {
      //   console.log("sign in")
      // }).catch(error => {
      //   console.log('sign in error', error)
      // })
    
  }
}
</script>

<style scoped lang="scss">

</style>

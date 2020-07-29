<template>
  <div class="columns is-desktop">
    <div class="column is-half is-offset-one-quarter">
      <h1 class="title is-2">Create Account</h1>
      <b-message v-if="message.show" :type="message.type" aria-close-label="Close message">
        {{message.content}}
      </b-message>
      <form @submit.prevent="onSubmit">
        <b-field v-for="field, key, id in formFields" :id="key" :key="key" :label="key | camel-to-space" :type="formFields[key].classType" :message="formFields[key].message">
          <b-input v-model="formFields[key].value" :type="formFields[key].type" :focus="loading = false"></b-input>
        </b-field>
        <invisible-recaptcha 
          :sitekey="siteKey" 
          :validate="loadButton" 
          :callback="onSubmit"
          class="button is-dark" type="submit" 
          id="captcha-btn" 
          :disabled="loading">
             Create
        </invisible-recaptcha>
<!--         <div class="buttons">
          <b-button native-type="submit" type="is-dark">Create</b-button>
        </div> -->
      </form>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import FormErrorHandlingMixin from '../mixins/FormErrorHandlingMixin'
import InvisibleRecaptcha from 'vue-invisible-recaptcha';

export default {
  name: 'registration',
  mixins: [FormErrorHandlingMixin],
  data () {
    return {
      loading: false,
      siteKey: "6LeM5qUZAAAAANv6TeUlvKGWPXhxmSSAcVO_HMeY",
      formFields: {
        name: { value: '', type: 'name', message: null, classType: null},
        email: { value: '', type: 'email', message: null, classType: null},
        password: { value: '', type: 'password', message: null, classType: null},
        passwordConfirmation: { value: '', type: 'password', message: null, classType: null},
      }
    }
  },
  components: {
    'invisible-recaptcha': InvisibleRecaptcha
  },
  methods: {
    loadButton: function() {
      this.loading = true
    },
    onSubmit: function () {
      console.log("i'm submitting")
      this.clearErrors();
      if(this.requiredFieldsErrors(['email', 'password', 'passwordConfirmation'])) {
        return
      };
      if(!this.passwordCheck()) {
        return
      };
      const formData = {
        name: this.formFields.name.value,
        email: this.formFields.email.value,
        password: this.formFields.password.value,
        password_confirmation: this.formFields.passwordConfirmation.value
      }

      // console.log(formData)
      // not using store method
      // axios.post('/api/sign_up', {user: formData })
      //   .then( res => {
      //     localStorage.setItem('auth_token', res.data.body.token)
      //     this.$store.commit('setToken', res.data.body.token);
      //     console.log(res)
      //     this.$cable.connection.connect();
      //     this.$router.replace({ path: '/' })
      //   })
      //   .catch( error => {
      //     console.log(error)
      //     this.showFieldErrors(error)
      //   })
      this.$store.dispatch('registerUser', formData).then((res) => {
        this.$router.replace({ path: '/' })
      }).catch(error => {
        console.log('registration error', error)
        this.showFieldErrors(error)
        // this.showGeneralMessage(error.response.data.statusText, 'is-danger')
      })
    }
  }
}
</script>

<style scoped >

</style>

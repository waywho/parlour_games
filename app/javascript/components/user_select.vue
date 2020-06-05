<template>
  <b-field label="Find a User">
    <b-autocomplete
        v-model="search"
        placeholder="e.g. Anne"
        :keep-first="false"
        :open-on-focus="true"
        :data="searchResults"
        @focus="searchUsers"
        @input="searchUsers"
        field="name"
        @select="option => selectUser(option)">
    </b-autocomplete>
  </b-field>
</template>

<script>
import parlourAxios from '../axios/axios_parlour.js';

export default {
  components: {

  },
  data: function () {
    return {
      search: '',
      searchResults: [],
      selectedUsers: []
    }
  },
  methods: {
    searchUsers: function() {
      this.search = ""
      if(this.search.length > 0) {
        parlourAxios.get(`/users?search=${this.search}`)
          .then(res => {
            // console.log(res)
            this.searchResults = res.data
          })
      } else {
        parlourAxios.get('/users')
          .then(res => {
            // console.log(res)
            this.searchResults = res.data.slice(0, 10)
          })
      }
    },
    selectUser: function(user) {
      if(user === null || user === undefined) {
        return }
      this.search = 'test'
      this.selectedUsers.push(user)
      this.$emit('users-select', this.selectedUsers)
    },
    removeUser: function(user) {
      var foundIndex = this.selectedUsers.indexOf(user)
      if(foundIndex > -1) {
        this.selectedUsers.splice(foundIndex, 1);
        this.$emit('users-remove', this.selectedUsers);
      }
    }
  }
}
</script>

<style scoped>

</style>

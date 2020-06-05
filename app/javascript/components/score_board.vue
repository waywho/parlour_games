<template>
  <table class="table">
    <thead>
      <tr>
        <th>Team</th>
        <th v-for="round in rounds">{{ round.name }}</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="team in teams">
        <td>{{team.name}}</td>
      </tr>
    </tbody>
  </table>
</template>

<script>

export default {
  props: ['teams', 'rounds'],
  data: function () {
    return {
      
    }
  },
  methods: {
    
  },
  created () {
    
    
  }
}
</script>

<style scoped>

</style>

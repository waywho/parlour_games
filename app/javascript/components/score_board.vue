<template>
  <table class="table has-text-centered">
    <thead>
      <tr>
        <th>Rounds</th>
        <th v-for="round in rounds" v-if="round.score_round">{{ round.name }}</th>
        <th>Total</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="team in teams">
        <td>{{team.name}}</td>
        <td v-for="(score, index) in team.scores">{{score}}</td>
        <td>{{team.scores | sumScore}}</td>
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
    
  }
}
</script>

<style scoped>

</style>

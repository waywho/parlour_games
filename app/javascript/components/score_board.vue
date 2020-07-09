<template>
  <table class="table has-text-centered">
    <thead>
      <tr v-if="totalOnly">
        <th>Rounds</th>
        <th>Total</th>
      </tr>
      <tr v-else>
        <th>Rounds</th>
        <th v-for="round in rounds" v-if="round.score_round">{{ round.name }}</th>
        <th>Total</th>
      </tr>
    </thead>
    <tbody v-if="totalOnly">
      <tr v-for="team in teams">
        <td>{{team.name}}</td>
        <td>{{team.scores | sumScore}}</td>
      </tr>
    </tbody>
    <tbody v-else>
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
  props: {
    teams: {
      type: Array,
      required: true
    }, 
    rounds: {
      type: Object,
      required: true
    },
    totalOnly: {
      type: Boolean,
      required: false,
      default: false
    }

  },
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

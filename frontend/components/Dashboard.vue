<template>
  <div class="content">
    <div class="pure-g">
      <div class="pure-u-1">
        <h3>Cards sums</h3>
        <table class="pure-table">
          <thead>
            <tr>
              <th>Card</th>
              <th>Sum</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="line in dashboardData.cardsData">
              <td>{{ line[0] }}</td>
              <td>{{ `${line[1]} BYN` }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="pure-u-1">
        <h3>Replenishments sums</h3>
        <table class="pure-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Sum</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="line in dashboardData.replenishmentsData">
              <td>{{ line[0] }}</td>
              <td>{{ `${line[1]} BYN` }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="pure-u-1">
        <h3>Expenses sums</h3>
        <table class="pure-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Sum</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="line in dashboardData.expencesData">
              <td>{{ line[0] }}</td>
              <td>{{ `${line[1]} BYN` }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
<script>
  import { mapState } from 'vuex';

  export default {
    computed: {
      ...mapState(['dashboardData'])
    }
  }
</script>
<style lang="css">
  table {
    width: 100%;
  }
</style>

<template>
  <div class="content">
    <div class="pure-g">
      <div class="pure-u-1 pure-u-md-1-3">
        <canvas id="cards-data" width="300" height="300" />
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
  import Chart from 'chart.js'

  export default {
    computed: {
      ...mapState(['dashboardData'])
    },

    watch: {
      dashboardData: {
        handler() {
          this.cardsChart.destroy()
          this.cardsChart = this.buildChart();
        }
      },

      deep: true
    },

    mounted() {
      this.cardsChart = this.buildChart()
    },

    methods: {
      buildChart() {
        const _this = this;

        return new Chart(document.getElementById('cards-data'), {
          type: 'doughnut',
          data: {
            datasets: [{
              data: _this.dashboardData.cardsData.map(el => el[1]),
              label: 'Cards',
              backgroundColor: [
                "rgb(54, 162, 235)",
                "rgb(255, 159, 64)",
                "rgb(255, 205, 86)",
                "rgb(75, 192, 192)",
                "rgb(54, 162, 235)"
              ].sort(() => Math.random() - 0.5)
            }],
            labels: _this.dashboardData.cardsData.map(el => el[0])
          },
          options: {
            responsive: true,
            legend: {
              position: 'top',
            },
            title: {
              display: true,
              text: 'Card\'s Balances'
            },
            animation: {
              animateScale: true,
              animateRotate: true
            }
          }
        })
      }
    }
  }
</script>
<style lang="css">
  table {
    width: 100%;
  }
</style>

<template>
  <div class="content">
    <div class="pure-menu pure-menu-horizontal">
      <ul class="pure-menu-list">
        <li class="pure-menu-item">
          <a
            href="#"
            class="pure-menu-link"
            v-on:click="tableName = 'cards'">
            Cards
          </a>
        </li>
        <li class="pure-menu-item">
          <a
            href="#"
            class="pure-menu-link"
            v-on:click="tableName = 'tags'">
            Tags
          </a>
        </li>
        <li class="pure-menu-item">
          <a
            href="#"
            class="pure-menu-link"
            v-on:click="tableName = 'replenishments'">
            Replenishments
          </a>
        </li>
        <li class="pure-menu-item">
          <a
            href="#"
            class="pure-menu-link"
            v-on:click="tableName = 'expenses'">
            Expenses
          </a>
        </li>
      </ul>
    </div>
    <div class="pure-g">
      <div class="pure-u-1">
        <h3>{{`${tableTitle} sum`}}</h3>
        <table class="pure-table">
          <thead>
            <tr>
              <th>{{tableTitle}}</th>
              <th>Sum</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="line in tableData">
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
  import axios from 'axios';
  import { mapState } from 'vuex';

  export default {
    props: ['tableName'],

    data: function() {
      return {
        tableData: [],
        tableName: 'cards'
      }
    },

    watch: {
      tableName() {
        this.fetchDashboardData()
      },

      filter: {
        handler(){
          this.fetchDashboardData()
        },
        deep: true
      }
    },

    computed: {
      ...mapState(['filter']),

      tableTitle() {
        return this.tableName.charAt(0).toUpperCase() + this.tableName.slice(1);
      }
    },

    created() {
      this.fetchDashboardData();
    },

    methods: {
      fetchDashboardData() {
        axios.get('/dashboard', { params: {...this.filter, ...{dasboard_table: this.tableName}} })
          .then(resp => this.tableData = resp.data.dashboard_table)
          .catch(err => console.log(err.error))
      }
    }
  }
</script>
<style lang="css">
  table {
    width: 100%;
  }
</style>

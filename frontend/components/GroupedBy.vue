<template>
  <section id="content">
    <nav class="navigation">
      <button
        class="pure-button pure-button-primary"
        v-on:click="$emit('navigateTo', 'Records')">
        <font-awesome-icon icon="long-arrow-alt-left" style="color: white" />
      </button>
      <span></span>
      <button
        class="pure-button"
        v-on:click="tableName = 'cards'">
        Card
      </button>
      <button
        class="pure-button"
        v-on:click="tableName = 'tags'">
        Tags
      </button>
      <button
        class="pure-button"
        v-on:click="tableName = 'replenishments'">
        Replenishments
      </button>
      <button
        class="pure-button"
        v-on:click="tableName = 'expenses'">
        Expenses
      </button>
      <span></span>
      <button
        class="pure-button"
        v-on:click="isOpenRecordFilterModal = true">
        <font-awesome-icon icon="filter" style="color: #777" />
      </button>
    </nav>
    <main class="grouped-by">
      <table class="pure-table">
        <thead>
          <tr>
            <th>{{tableTitle}}</th>
            <th>Sum</th>
          </tr>
          <tr>
          </tr>
        </thead>
        <tbody>
          <tr v-for="line in tableData">
            <td>{{ line[0] }}</td>
            <td>{{ `${line[1]} BYN` }}</td>
          </tr>
        </tbody>
      </table>
    </main>
    <ModalWindow v-if='isOpenRecordFilterModal' v-on:close='isOpenRecordFilterModal = false'>
      <h3 slot="header">Filter records</h3>
      <RecordFilter
        slot='body'
        v-on:close='isOpenRecordFilterModal = false'/>
    </ModalWindow>
  </section>
</template>
<script>
  import axios from 'axios';
  import RecordFilter from './statements/RecordFilter.vue'
  import ModalWindow from './ModalWindow.vue'
  import { library } from '@fortawesome/fontawesome-svg-core'
  import { faFilter, faLongArrowAltLeft } from '@fortawesome/free-solid-svg-icons'
  import { mapState } from 'vuex';

  library.add(faFilter, faLongArrowAltLeft)

  export default {
    components: {
      RecordFilter,
      ModalWindow
    },

    data: function() {
      return {
        tableData: [],
        tableName: 'cards',
        isOpenRecordFilterModal: false
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
<style lang="css" scoped>
  table {
    width: 100%;
  }

  .navigation {
    display: grid;
    grid-template-columns: 1fr 3fr 1fr 1fr 1fr 1fr 3fr 1fr;
    grid-gap: 5px;
    padding: 0 20px 5px 20px;
  }

  @media (max-width: 1024px) {
    .navigation {
      width: calc(100vw - 40px);
      overflow-y: scroll;
      grid-template-columns: repeat(8, 1fr);
    }
  }

  .grouped-by {
    height: calc(85vh - 20px);
    overflow-y: scroll;
    -webkit-overflow-scrolling: touch;
    padding: 20px;
  }
</style>

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
    <main class="grouped-by" v-bind:touchmove="e => e.preventDefault()">
      <article class="grouped-row-header">
        <section></section>
        <section>BYN</section>
      </article>
      <article class="grouped-row" v-for="row in tableData">
        <section class="grouped-name" v-bind:title="row[0]">{{ row[0] }}</section>
        <section class="grouped-sum">{{ row[1] }}</section>
      </article>
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

  .grouped-row, .grouped-row-header {
    padding: 5px 0;
    display: grid;
    grid-template-columns: 70% 30%;
    grid-template-rows: 30px;
    align-items: center;
  }

  .grouped-row .grouped-sum {
    font-weight: 600;
  }

  .grouped-row-header section, .grouped-row .grouped-sum {
    justify-self: end;
  }

  .grouped-row .grouped-name {
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
  }

  @supports (-webkit-overflow-scrolling: touch) {
    .grouped-by {
      height: calc(100vh - 30vh);
    }
  }
</style>

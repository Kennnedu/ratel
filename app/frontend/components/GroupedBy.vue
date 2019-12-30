<template>
  <section id="content">
    <nav class="navigation">
      <button
        title="Back to main page"
        class="pure-button pure-button-primary"
        v-on:click="$emit('navigateTo', 'Records')">
        <font-awesome-icon icon="long-arrow-alt-left" style="color: white" />
      </button>
      <div class="pure-button-group" role="group">
        <button
          title="Cards"
          class="pure-button"
          v-on:click="tableName = 'cards'"
          v-bind:class="{'pure-button-active': tableName === 'cards'}">
          <font-awesome-icon icon="credit-card" style="color: #777" />
          <span class="button-text">Sources</span>
        </button>
        <button
          title="Tags"
          class="pure-button"
          v-on:click="tableName = 'tags'"
          v-bind:class="{'pure-button-active': tableName === 'tags'}">
          <font-awesome-icon icon="tags" style="color: #777" />
          <span class="button-text">Tags</span>
        </button>
        <button
          title="Replenishment"
          class="pure-button"
          v-on:click="tableName = 'replenishments'"
          v-bind:class="{'pure-button-active': tableName === 'replenishments'}">
          <font-awesome-icon icon="hand-holding-usd" style="color: #777" />
          <span class="button-text">Income</span>
        </button>
        <button
          title="Expenses"
          class="pure-button"
          v-on:click="tableName = 'expenses'"
          v-bind:class="{'pure-button-active': tableName === 'expenses'}">
          <font-awesome-icon icon="receipt" style="color: #777" />
          <span class="button-text">Expense</span>
        </button>
      </div>
      <button
        title="Filter By Records"
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
      <RecordFilter slot='body'/>
    </ModalWindow>
  </section>
</template>
<script>
  import axios from 'axios';
  import RecordFilter from './statements/RecordFilter.vue'
  import ModalWindow from './ModalWindow.vue'
  import { library } from '@fortawesome/fontawesome-svg-core'
  import { faFilter, faLongArrowAltLeft, faHandHoldingUsd, faCreditCard, faTags, faReceipt } from '@fortawesome/free-solid-svg-icons'
  import { mapState } from 'vuex';

  library.add(faFilter, faLongArrowAltLeft, faHandHoldingUsd, faCreditCard, faTags, faReceipt)

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
  .navigation {
    display: grid;
    grid-template-columns: 1fr 10fr 1fr;
    grid-gap: 5px;
    padding: 0 20px 5px 20px;
  }

  .navigation .pure-button-group {
    justify-self: center;
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
    border-radius: 3px;
  }

  .grouped-row .grouped-sum {
    font-weight: 600;
  }

  .grouped-row-header section, .grouped-row .grouped-sum {
    justify-self: end;
  }

  .grouped-row section:nth-child(1), .grouped-row-header section:nth-child(1) {
    padding-left: 10px;
  }

  .grouped-row section:nth-child(2), .grouped-row-header section:nth-child(2) {
    padding-right: 10px;
  }

  .grouped-row .grouped-name {
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
  }

  .grouped-row:hover, .grouped-row:active {
    background-color: #e0e0e0;
  }

  @media (max-width: 1024px) {
    .navigation {
      width: calc(100vw - 40px);
      overflow-y: scroll;
    }

    .grouped-by {
      box-shadow: inset 0 7px 9px -7px #777;
    }

    .grouped-row section:nth-child(1), .grouped-row-header section:nth-child(1) {
      padding-left: 0;
    }

    .grouped-row section:nth-child(2), .grouped-row-header section:nth-child(2) { 
      padding-right: 0;
    }

    nav.navigation div.pure-button-group button.pure-button span.button-text {
      font-size: 0px;
    }
  }

  @supports (-webkit-overflow-scrolling: touch) {
    .grouped-by {
      height: calc(100vh - 30vh);
    }
  }
</style>

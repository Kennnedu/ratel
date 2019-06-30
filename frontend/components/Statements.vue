<template>
  <div class="content">
    <button class="pure-button pure-button-primary add-new-record"
            v-on:click="isOpenNewRecordModal = true">
      + Add new Record
    </button>
    <h2>Total Records: {{ totalCount }}</h2>
    <RecordFetcher
      v-bind:filter="filter"
      v-on:updateRecords="updateRecords"
      v-on:updateFilter="updateFilter"/>
    <div class="pure-g record-cards">
      <Record
        v-for="record in records"
        v-bind:key="record.id"
        v-bind:record="record"
        v-on:updateRecords="updateRecords"
        v-on:addFilteringName="addFilteringName" />
    </div>
    <ModalWindow v-if='isOpenNewRecordModal' v-on:close='isOpenNewRecordModal = false'>
      <h3 slot="header">New Record</h3>
      <RecordForm
        slot='body'
        v-on:save='() => { isOpenNewRecordModal = false; updateRecords() }'/>
    </ModalWindow>
  </div>
</template>
<script>
  import Record from './statements/Record.vue'
  import RecordFetcher from './statements/RecordFetcher.vue'
  import ModalWindow from './ModalWindow.vue'
  import RecordForm from './statements/RecordForm.vue'
  import moment from 'moment'
  import { mapState, mapGetters, mapActions } from 'vuex';

  export default {
    components: { Record, RecordFetcher, ModalWindow, RecordForm },

    data: function() {
      return {
        isOpenNewRecordModal: false,
        filter: {
          name: "",
          card: "",
          from: moment().set('month', moment().get('month') - 1).format('YYYY-MM-DD'),
          to: moment().format('YYYY-MM-DD')
        }
      }
    },

    computed: {
      ...mapState(['records', 'totalSum']),
      ...mapGetters(['totalCount'])
    },

    methods: {
      ...mapActions([ 'fetchRecords' ]),

      updateRecords() {
        this.fetchRecords(this.filter)
      },

      updateFilter(changes) {
        this.filter = Object.assign({}, this.filter, changes)
      },

      addFilteringName(name) {
        this.filter.name = this.filter.name.length === 0 ? name : `${this.filter.name}&${name}`
      }
    }
  }
</script>
<style lang="css">
  .record-cards {
    margin-top: 10px;
  }
  .add-new-record {
    float: right;
  }
</style>

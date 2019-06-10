<template>
  <div class="content">
    <button class="pure-button pure-button-primary add-new-record"
            v-on:click="isOpenNewRecordModal = true">
      + Add new Record
    </button>
    <h2>Total Records: {{ records.length }}</h2>
    <h2>Total Sum: {{ totalSum }}</h2>
    <RecordFetcher v-bind:isOutdated="isOutdated" v-on:updateStatement="updateStatement" />
    <div class="pure-g record-cards">
      <Record v-for="record in records"
                v-bind:key="record.id"
                v-bind:record="record"
                v-on:hasChanges="isOutdated = true" />
    </div>
    <ModalWindow v-if='isOpenNewRecordModal' v-on:close='isOpenNewRecordModal = false'>
      <h3 slot="header">New Record</h3>
      <RecordForm slot='body' v-on:save="isOutdated = true; isOpenNewRecordModal = false"/>
    </ModalWindow>
  </div>
</template>
<script>
  import Record from './statements/Record.vue'
  import RecordFetcher from './statements/RecordFetcher.vue'
  import ModalWindow from './ModalWindow.vue'
  import RecordForm from './statements/RecordForm.vue'

  export default {
    components: { Record, RecordFetcher, ModalWindow, RecordForm },
    data: function() {
      return {
        records: [],
        totalSum: 0,
        isOutdated: false,
        isOpenNewRecordModal: false
      }
    },
    methods: {
      updateStatement(respond){
        this.records = respond.records;
        this.totalSum = respond.total_sum;
        this.isOutdated = false;
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

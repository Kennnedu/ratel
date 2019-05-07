<template>
  <div class="content">
    <h2>Total Records {{ records.length }}</h2>
    <RecordFilter v-on:assingRecords="assingRecords" />
    <div class="record-cards">
      <Record v-for="record in records"
                v-bind:key="record.id"
                v-bind:record="record"
                v-on:destroy="destroyRecord" />
    </div>
  </div>
</template>
<script>
  import Record from './statements/Record.vue'
  import RecordFilter from './statements/RecordFilter.vue'

  export default {
    components: { Record, RecordFilter },
    data: function() {
      return {
        records: []
      }
    },
    methods: {
      assingRecords(records){
        this.records = records
      },
      destroyRecord(id){
        this.records = this.records.filter(record => record.id !== id)
      }
    }
  }
</script>
<style lang="css">
  .record-cards {
    display: flex;
    flex-wrap: wrap;
    margin-top: 10px;
  }
</style>
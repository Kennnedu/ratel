<template>
  <div class="content">
    <h2>Total Records: {{ records.length }}</h2>
    <h2 v-on:click="">Total Sum: {{ totalSum }}</h2>
    <RecordFilter v-on:assingRecords="assingRecords" />
    <div class="pure-g record-cards">
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
        records: [],
        totalSum: 0
      }
    },
    methods: {
      assingRecords(respond){
        this.records = respond.records;
        this.totalSum = respond.total_sum
      },
      destroyRecord(id){
        this.records = this.records.filter(record => record.id !== id)
      }
    }
  }
</script>
<style lang="css">
  .record-cards {
    margin-top: 10px;
  }
</style>
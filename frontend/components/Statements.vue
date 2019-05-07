<template>
  <div class="content">
    <div class="pure-g">
      <div class="pure-u-1">
        <h3>Total {{ records.length }}</h3>
      </div>
    </div>
    <div class="record-cards">
      <Record v-for="record in records"
                v-bind:key="record.id"
                v-bind:record="record"
                v-on:destroy="destroyRecord" />
    </div>
  </div>
</template>
<script>
  import axios from 'axios'
  import Record from './statements/Record.vue'

  export default {
    components: { Record },
    data: function() {
      return {
        records: []
      }
    },
    created: function() {
      let _this = this;

      axios.get('/records').then(function(data){
        _this.records = data.data
      })
      .catch(function(error){
        console.log(error);
      })
    },
    methods: {
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
  }
</style>
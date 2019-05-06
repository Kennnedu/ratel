<template>
  <div class="content">
    <div class="pure-g">
      <div class="pure-u-1">
        <h3>Total {{ records.length }}</h3>
      </div>
    </div>
    <table class="pure-table pure-table-bordered">
      <thead>
        <tr>
          <th>Operaion</th>
          <th>Card</th>
          <th>Amount</th>
          <th>Rest</th>
          <th>Performed At</th>
        </tr>
      </thead>
      <tbody>
        <Record v-for="record in records"
                v-bind:key="record.id"
                v-bind:record="record" />
      </tbody>
    </table>
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
    }
  }
</script>
<style></style>
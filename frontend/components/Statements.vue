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
          <th>Name</th>
          <th>Card</th>
          <th>Amount</th>
          <th>Rest</th>
          <th>Performed At</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="record in records"
            v-bind:key="record.id">
          <td>{{ record.name }}</td>
          <td>{{ record.card }}</td>
          <td>{{ `${record.amount} BYN` }}</td>
          <td>{{ `${record.rest} BYN` }}</td>
          <td>{{ moment(record.performed_at).format('lll') }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
  import axios from 'axios'
  import moment from 'moment'

  export default {
    data: function() {
      return {
        records: [],
        moment: moment
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
<template>
  <div id="statements">
    <div class="header">
      <h1>Statements</h1>
      <h2>The page lets you know your all statements</h2>
    </div>
    <div class="content">
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
            <td>{{ record.amount }}</td>
            <td>{{ record.rest }}</td>
            <td>{{ record.performed_at }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
<script>
  import axios from 'axios'

  export default {
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
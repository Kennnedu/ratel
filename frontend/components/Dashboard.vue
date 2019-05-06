<template>
  <div class="content">
    <div class="pure-g">
      <div class="pure-u-1">
        <h3>Report</h3>
      </div>
    </div>
    <table class="pure-table">
      <thead>
        <tr>
          <th>Name</th>
          <th>Amount Sum</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="line in report">
          <td>{{ line[0] }}</td>
          <td>{{ `${line[1]} BYN` }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
  import axios from 'axios'

  export default {
    data: function(){
      return {
        report: []
      }
    },
    created: function(){
      let _this = this;

      axios.get('/records/report').then(function(data){
        _this.report = data.data
      })
      .catch(function(error){
        console.log(error);
      })
    }
  }
</script>
<style lang="css">
  table {
    width: 100%;
  }
</style>
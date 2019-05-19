<template>
  <div class="content">
    <div class="pure-g">
      <div class="pure-u-1">
        <h3>Group by cards</h3>
        <table class="pure-table">
          <thead>
            <tr>
              <th>Card</th>
              <th>Amount Sum</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="line in groupByCard">
              <td>{{ line[0] }}</td>
              <td>{{ `${line[1]} BYN` }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="pure-u-1">
        <h3>Group by names</h3>
        <table class="pure-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Amount Sum</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="line in groupByName">
              <td>{{ line[0] }}</td>
              <td>{{ `${line[1]} BYN` }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
<script>
  import axios from 'axios'

  export default {
    data: function(){
      return {
        groupByName: [],
        groupByCard: []
      }
    },
    created: function(){
      let _this = this;

      axios.get('/records/report').then(function(data){
        console.log(data.data);
        _this.groupByName = data.data.group_by_name
        _this.groupByCard = data.data.group_by_card
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
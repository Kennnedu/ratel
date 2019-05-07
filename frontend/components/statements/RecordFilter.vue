<template>
  <div class="pure-g">
    <div class="pure-u-1-5">
      <h3>Filtering:</h3>
    </div>
    <form class="pure-u-4-5 pure-form pure-g">
      <input type="string"
             class="pure-u-1-3 pure-input-rounded"
             placeholder="By operation"
             v-model="filter.name" />
      <input type="string"
             class="pure-u-1-3 pure-input-rounded"
             placeholder="By card"
             v-model="filter.card" />
      <fieldset class="pure-u-1">
        From <input type="date"
                    class="pure-u-1-3" 
                    v-model="filter.from" /> 
        To <input type="date"
                  class="pure-u-1-3" 
                  v-model="filter.to" />
      </fieldset>
    </form>
  </div>
</template>
<script>
import axios from 'axios'
import moment from 'moment'
import lodash from 'lodash'

export default {
  data: function(){
    return {
      filter: {
        name: "",
        card: "",
        from: moment().set('month', moment().get('month') - 1).format('YYYY-MM-DD'),
        to: moment().format('YYYY-MM-DD')
      }
    }
  },
  watch: {
    filter: {
      handler: function(){ 
        this.debouncedFetchRecords()
      },
      deep: true
    }
  },
  created: function() {
    this.debouncedFetchRecords = _.debounce(this.fetchRecords, 500);
    this.fetchRecords();
  },
  methods: {
    fetchRecords(){
      let _this = this;

      axios.get('/records', { params: _this.filter})
      .then(function(data){
        _this.$emit('assingRecords', data.data);
      })
      .catch(function(error){
        console.log(error);
      })
    }
  }
}
</script>
<style lang="css">
</style>
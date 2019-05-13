<template>
  <form class="pure-form pure-form-stacked">
    <fieldset>
      <legend>Filter</legend>
    <div class="pure-g">
      <div class="pure-u-1 pure-u-md-2-5">
        <label for="filter-operation">By operation</label>
        <input type="text"
                id="filter-operation"
                class="pure-u-23-24"
                v-model="filter.name" />
      </div>
      <div class="pure-u-1 pure-u-md-2-5">
        <label for="filter-card">By card</label>
        <input type="text"
                id="filter-card"
                class="pure-u-23-24"
                v-model="filter.card" />
      </div>
      <div class="pure-u-1 pure-u-md-2-5">
        <label for="filter-from">From</label>
        <input type="date"
                id="filter-from"
                class="pure-u-23-24"
                v-model="filter.from" />
      </div>
      <div class="pure-u-1 pure-u-md-2-5">
        <label for="filter-to">To</label>
        <input type="date"
                id="filter-to"
                class="pure-u-23-24"
                v-model="filter.to" />
      </div>
    </div>
    </fieldset>
  </form>
</template>
<script>
import axios from 'axios'
import moment from 'moment'
import lodash from 'lodash'

export default {
  props: ['isOutdated'],
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
    },
    isOutdated: function(newValue, oldValue){
      if(newValue){
        this.fetchRecords()
      }
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
        _this.$emit('updateStatement', data.data);
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
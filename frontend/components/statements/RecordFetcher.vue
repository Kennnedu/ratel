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
                v-bind:value="filter.name"
                v-on:input="$emit('updateFilter', { name: $event.target.value })"/>
      </div>
      <div class="pure-u-1 pure-u-md-2-5">
        <label for="filter-card">By card</label>
        <input type="text"
                id="filter-card"
                class="pure-u-23-24"
                v-bind:value="filter.card"
                v-on:input="$emit('updateFilter', { card: $event.target.value })" />
      </div>
      <div class="pure-u-1 pure-u-md-2-5">
        <label for="filter-from">From</label>
        <input type="date"
                id="filter-from"
                class="pure-u-23-24"
                v-bind:value="filter.from"
                v-on:input="$emit('updateFilter', { from: $event.target.value })" />
      </div>
      <div class="pure-u-1 pure-u-md-2-5">
        <label for="filter-to">To</label>
        <input type="date"
                id="filter-to"
                class="pure-u-23-24"
                v-bind:value="filter.to"
                v-on:change="e => $emit('updateFilter', { to: e.target.value })" />
      </div>
    </div>
    </fieldset>
  </form>
</template>
<script>
import axios from 'axios'
import lodash from 'lodash'

export default {
  props: ['isOutdated', 'filter'],

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

  mounted() {
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
        console.log(error.response);
      })
    }
  }
}
</script>
<style lang="css">
</style>

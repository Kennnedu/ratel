<template>
  <form class="pure-form pure-form-stacked">
    <fieldset>
      <div class="pure-control-group">
        <label for="filter-operation">By operation</label>
        <input type="text"
                id="filter-operation"
                v-bind:value="filter.name"
                v-on:input="e => updateFilter({changes: { name: e.target.value }})"/>
      </div>
      <div class="pure-control-group">
        <label for="filter-card">By card</label>
        <input type="text"
                id="filter-card"
                v-bind:value="filter.card"
                v-on:input="e => updateFilter({changes: { card: e.target.value }})" />
      </div>
      <div class="pure-control-group">
        <label for="filter-from">From</label>
        <input type="date"
                id="filter-from"
                v-bind:value="filter.from"
                v-on:input="e => updateFilter({changes: { from: e.target.value }})" />
      </div>
      <div class="pure-control-group">
        <label for="filter-to">To</label>
        <input type="date"
                id="filter-to"
                v-bind:value="filter.to"
                v-on:change="e => updateFilter({changes: { to: e.target.value }})" />
      </div>
    </fieldset>
    <input
      type="button"
      value="Reset"
      class="pure-button"
      v-on:click="resetFilter" 
    />
  </form>
</template>
<script>
import lodash from 'lodash'
import { mapState, mapMutations } from 'vuex'

export default {
  computed: {
    ...mapState(['filter'])
  },

  methods: {
    ...mapMutations(['updateFilter', 'resetFilter'])
  }
}
</script>
<style lang="css">
</style>

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
        <label for="filter-tags">By tag</label>
        <input type="text"
               id="filter-card"
               v-bind:value="filter.tags"
               v-on:input="e => updateFilter({changes: { tags: e.target.value }})" />
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
      v-on:click="() => updateFilter({changes: defFilter})" 
    />
    <input
      type="button"
      value="Save as Default"
      class="pure-button"
      v-bind:disabled="isEqlFilterToDefFilter"
      v-on:click="saveDefFilter"/>
  </form>
</template>
<script>
import { mapState, mapMutations } from 'vuex'

export default {
  data: function(){
    return {
      defFilter: {}
    }
  },

  computed: {
    ...mapState(['filter']),

    isEqlFilterToDefFilter() {
      const defFilter = this.defFilter;
      const filter= this.filter;

      return filter.name === defFilter.name && filter.card === defFilter.card &&
        filter.from === defFilter.from && filter.to === defFilter.to && filter.tags === defFilter.tags
    }
  },

  methods: {
    ...mapMutations(['updateFilter', 'resetFilter']),

    saveDefFilter() {
      this.defFilter = this.filter;
      localStorage.setItem('defaultFilter', JSON.stringify(this.filter));
    }
  },

  created() {
    const savedDefFilter = JSON.parse(localStorage.getItem('defaultFilter'));

    this.defFilter = savedDefFilter || this.filter;
  }
}
</script>
<style lang="css">
</style>

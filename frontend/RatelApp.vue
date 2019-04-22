<template>
  <div id="ratel-app">
    <Navigation v-bind:current-page="currentPage" v-on:navigateTo="navigateTo">
      <Dashboard v-if="currentPage === 'Dashboard'"/>
      <Uploading v-if="currentPage === 'Uploading'"/>
      <Statements v-if="currentPage === 'Statements'"/>
    </Navigation>
  </div>
</template>

<script>
  import Navigation from './Navigation.vue'
  import Statements from './Statements.vue'
  import Uploading from './Uploading.vue'
  import Dashboard from './Dashboard.vue'

  export default {
    components: {
      Navigation,
      Statements,
      Uploading,
      Dashboard
    },
    data: function(){
      return {
        currentPage: 'Dashboard'
      }
    },
    methods: {
      navigateTo: function(page){
        this.currentPage = page
      }
    }
  }
</script>

<style lang="scss">
</style>

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
  import Navigation from './components/Navigation.vue'
  import Statements from './components/Statements.vue'
  import Uploading from './components/Uploading.vue'
  import Dashboard from './components/Dashboard.vue'
  import axios from 'axios'

  export default {
    components: {
      Navigation,
      Statements,
      Uploading,
      Dashboard
    },
    data: function(){
      return {
        currentPage: 'Statements',
        logged: true
      }
    },
    created() {
      let _this = this;

      axios.interceptors.response.use(function(response){
      }, function(error){
        if(error.response.status === 401) _this.logged = false;
      })
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

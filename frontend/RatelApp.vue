<template>
  <div id="ratel-app">
    <Login v-if="!logged" v-on:login="logged = true" />
    <Navigation v-bind:current-page="currentPage" v-on:navigateTo="navigateTo" v-if="logged">
      <Dashboard v-if="currentPage === 'Dashboard'"/>
      <Statements v-show="currentPage === 'Records'"/>
      <Cards v-if="currentPage === 'Cards'" />
    </Navigation>
  </div>
</template>

<script>
  import Navigation from './components/Navigation.vue'
  import Statements from './components/Statements.vue'
  import Dashboard from './components/Dashboard.vue'
  import Cards from './components/Cards.vue'
  import Login from './components/Login.vue'
  import axios from 'axios'

  export default {
    components: {
      Navigation,
      Statements,
      Dashboard,
      Cards,
      Login
    },
    data: function(){
      return {
        currentPage: 'Records',
        logged: true
      }
    },
    created() {
      let _this = this;

      axios.interceptors.response.use(function(response){
        return response
      }, function(error){
        if(error.response.status === 401) _this.logged = false;
        return Promise.reject(error);
      })
    },
    methods: {
      navigateTo: function(page){
        this.currentPage = page
      }
    }
  }
</script>

<style lang="css">
  .button-error {
    background: rgb(202, 60, 60);
    color: white;
    text-shadow: 0 1px 1px rgba(0, 0, 0, 0.2);
  }
</style>

<template>
  <header id="header">
    <em>Count: {{totalRecords}}</em>
    <em>Sum: {{totalSum}}</em>
  </header>
</template>
<script>
  import { mapState } from 'vuex';

  export default {
    computed: {
      ...mapState(['totalSum', 'totalRecords'])
    }
  }
</script>
<style lang="css" scoped>
  header {
    padding: 5px;
    text-align: center;
  }

  header :first-child {
    margin-right: 10px;
  }
</style>

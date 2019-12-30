<template>
  <header id="header">
    <em title="Balance" v-bind:class="totalSum > 0 ? 'balance-positive' : 'balance-negative'">{{Math.abs(totalSum)}}</em>
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

  header#header em.balance-positive {
    font-size: 20px;
    color: rgb(28, 184, 65)
  }

  header#header em.balance-negative {
    font-size: 20px;
    color: rgb(202, 60, 60)
  }

  header#header em.balance-positive:before {
    content: '+ '
  }

  header#header em.balance-negative:before {
    content: '- '
  }
</style>

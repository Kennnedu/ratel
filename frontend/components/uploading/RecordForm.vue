<template>
  <form class="pure-form pure-form-stacked">
  </form>
</template>
<script>
  import axios from 'axios'

  export default {
    data: function(){
      return {
        record: {
          name: '',
          card: '',
          amount: 0.0,
          rest: 0.0,
          performedAt: new Date()
        },
        errors: [],
        saveButtonName: 'Saving'
      }
    }
  }
</script>
<style lang="css" scoped>
  .pure-form-message.pure-form-message-error {
    color: red;
  }
</style>
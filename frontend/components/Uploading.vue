<template>
  <div class="content">
    <RecordForm/>
    <HtmlStatementsForm/>
  </div>
</template>
<script>
  import axios from 'axios'
  import RecordForm from './uploading/RecordForm.vue'
  import HtmlStatementsForm from './uploading/HtmlStatementsForm.vue'

  export default {
    components: { HtmlStatementsForm, RecordForm }
  }
</script>
<style lang="css" scoped>
  #statements-html{
    width: 100%;
    height: 15vw;
  }

  .pure-form-message.pure-form-message-error {
    color: red;
  }
</style>
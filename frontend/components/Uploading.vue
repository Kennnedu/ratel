<template>
  <div id="uploading">
    <div class="header">
      <h1>Uploading</h1>
      <h2>The page allows you to upload new statements</h2>
    </div>
    <div class="content">
      <RecordForm/>
      <HtmlStatementsForm/>
    </div>
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
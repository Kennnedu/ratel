<template>
  <div class="content">
    <HtmlStatementsForm/>
  </div>
</template>
<script>
  import HtmlStatementsForm from './uploading/HtmlStatementsForm.vue'

  export default {
    components: { HtmlStatementsForm }
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
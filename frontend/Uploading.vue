<template>
  <div id="uploading">
    <div class="header">
      <h1>Uploading</h1>
      <h2>The page allows you to upload new statements</h2>
    </div>
    <div class="content">
      <form class="pure-form pure-form-stacked">
        <fieldset>
          <label for="statements-html">Statements HTML</label>
          <textarea id="statements-html" placeholder="Past your statements html table" required/>
          <span class="pure-form-message" v-if="false">This is a required field.</span>
        </fieldset>
        <input type="submit" class="pure-button pure-button-primary" value="Submit">
      </form>
    </div>
  </div>
</template>
<script>
  export default {
  }
</script>
<style lang="css" scoped>
  #statements-html{
    width: 100%;
  }
</style>
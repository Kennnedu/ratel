<template>
  <form class="pure-form pure-form-stacked">
    <fieldset>
      <label for="card-name">Name</label>
      <input type="text" id="card-name" placeholder="Enter card name" v-model="card.name" required>
    </fieldset>

    <input type="submit" v-bind:value="saveButtonName" class="">
  </form>
</template>
<script>
import { mapState } from 'vuex'

export default {
  props: ['card'],

  data: function(){
    return {
      card: {},
      saveButtonName: "Save"
    }
  }
}
</script>
<style lang="css" scoped>
</style>

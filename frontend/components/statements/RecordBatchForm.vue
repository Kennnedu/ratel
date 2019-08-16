<template>
  <form class="pure-form pure-form-stacked" v-on:submit="submitForm">
    <fieldset>
      <TagsInput
          v-bind:recordsTags="batchForm.recordsTags"
          v-on:change="newRecordsTags => batchForm.recordsTags = newRecordsTags" />
      <label for="record-batch-name">Operation</label>
      <input type="text" id="record-batch" placeholder="Enter operation" v-model.trim="batchForm.name">
    
      <label>Card</label>
      <CardSelector
        v-bind:card="batchForm.card"
        v-on:selectCard="newCard => batchForm.card = newCard"/>
    </fieldset>

    <input type="submit" class="pure-button pure-button-primary" v-bind:value="submitButtonName" />
    <input type="button" class="pure-button button-error" value="Destroy All" />
  </form>
</template>
<script>
import axios from 'axios'
import { mapState, mapActions } from 'vuex'
import TagsInput from '../TagsInput.vue'
import CardSelector from '../CardSelector.vue'

export default {
  components: {
    TagsInput,
    CardSelector
  },

  data: function() {
    return {
      batchForm: {
        name: '',
        recordsTags: [],
        card: {}
      },

      submitButtonName: 'Apply changes'
    }
  },

  computed: {
    ...mapState(['filter'])
  },

  methods: {
    ...mapActions(['fetchRecords']),

    submitForm() {
      axios.put('/records/batch', {...this.filter, ...{ batch_form: this.batchForm } })
        .then(res => console.log(res))
        .catch(err => console.log(err))
    }
  }
}
</script>
<style lang="css">
</style>
<template>
  <form class="pure-form pure-form-stacked" v-on:submit="submitForm" title='Эта форма может отредактировать всю отфильтрованную выборку записей'>
    <fieldset>
      <label> Add tags </label>
      <TagsInput
        v-bind:recordsTags="batchForm.addRecordsTags"
        v-on:change="newRecordsTags => batchForm.addRecordsTags = newRecordsTags" />

      <label> Remove Tags </label>
      <TagsInput
        v-bind:recordsTags="batchForm.removeRecordsTags"
        v-on:change="newRecordsTags => batchForm.removeRecordsTags = newRecordsTags" />
      <label for="record-batch-name">Operation</label>
      <input type="text" id="record-batch" placeholder="Enter operation" v-model.trim="batchForm.name">
    
      <label>Card</label>
      <CardSelector
        v-bind:card="batchForm.card"
        v-on:selectCard="newCard => batchForm.card = newCard"/>
    </fieldset>

    <input 
      type="submit"
      class="pure-button pure-button-primary"
      v-bind:disabled="!validBatchForm"
      v-bind:value="submitButtonName" />
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
        addRecordsTags: [],
        removeRecordsTags: [],
        card: {}
      },

      submitButtonName: 'Apply changes',
      isDisabledSubmit: true
    }
  },

  computed: {
    ...mapState(['filter']),

    validBatchForm() {
      const { name, card, addRecordsTags, removeRecordsTags } = this.batchForm
      return name.length > 0 || card.id || addRecordsTags.length > 0 || removeRecordsTags.length > 0
    }
  },

  methods: {
    ...mapActions(['fetchRecords']),

    submitForm(e) {
      e.preventDefault();
      this.submitButtonName = 'Saving...'

      axios.put('/records/batch', this.sendingParams())
        .then(res => {
          this.submitButtonName = 'Apply changes';
          this.fetchRecords();
          this.$emit('close');
        })
        .catch(err => console.log(err))
    },

    sendingParams() {
      const { batchForm, filter } = this
      let fd = new FormData();

      Object.keys(filter).forEach(el => fd.append(`filter[${el}]`, filter[el]));

      if(batchForm.name.length > 0) fd.append('batch_form[name]', batchForm.name)
      if(batchForm.card.id) fd.append('batch_form[card_id]', batchForm.card.id)
      if(batchForm.addRecordsTags.length > 0) {
        batchForm.addRecordsTags.forEach(recTag => fd.append('batch_form[records_tags_attributes][][tag_id]', recTag.tag_id))
      }

      if(batchForm.removeRecordsTags.length > 0) {
        batchForm.removeRecordsTags.forEach(recTag => fd.append('removing_tag_ids[]', recTag.tag_id))
      }

      return fd
    }
  }
}
</script>
<style lang="css">
</style>
<template>
  <form class="pure-form pure-form-stacked" v-on:submit="submitForm">
    <fieldset>
      <TagsInput
        v-bind:recordsTags="currentRecord.records_tags"
        v-on:change="newRecordsTags => currentRecord.records_tags = newRecordsTags" />

      <label for="record-name">Operation</label>
      <RecordNameInput
        v-bind:recordName="currentRecord.name"
        v-bind:isRequired="true"
        v-on:change="newName => currentRecord.name = newName" />

      <label for="record-card">Card</label>
      <CardSelector
        v-bind:required="true"
        v-bind:card="currentRecord.card"
        v-on:selectCard="newCard => currentRecord.card = newCard"/>

      <label for="record-amount">Amount</label>
      <input type="number" id="record-amount" step="0.01" required v-model.number="currentRecord.amount">

      <label for="record-rest">Rest</label>
      <input type="number" id="record-rest" step="0.01" v-model.number="currentRecord.rest">

      <label for="record-performed-at">Performed At</label>
      <input type="datetime-local" id="record-performed-at" v-model="currentRecord.performed_at">
    </fieldset>
    <input type="submit"
           class="pure-button pure-button-primary"
           v-bind:value="saveButtonName"/>
    <input type="button"
           class="pure-button button-error"
           value="Delete"
           v-on:click="destroy"
           v-if="currentRecord.id"/>
  </form>
</template>
<script>
  import axios from 'axios'
  import moment from 'moment'
  import { mapActions, mapGetters } from 'vuex'
  import CardSelector from '../CardSelector.vue'
  import TagsInput from '../TagsInput.vue'
  import RecordNameInput from '../RecordNameInput.vue'

  const emptyNewRecord = () => {
    return {
      name: '',
      card: {},
      amount: 0.0,
      rest: 0.0,
      records_tags: [],
      performed_at: moment().format('YYYY-MM-DDTHH:mm')
    }
  }

  const initCurrentRecord = (record) => {
    if (record) {
      return Object.assign({}, record, { performed_at: moment(record.performed_at).format('YYYY-MM-DDTHH:mm')});
    } else {
      return Object.assign({}, emptyNewRecord());
    }
  }

  export default {
    components: { CardSelector, TagsInput, RecordNameInput },

    props: ['record'],

    data: function(){
      return {
        currentRecord: initCurrentRecord(this.record),
        errors: [],
        saveButtonName: this.record ? 'Update' : 'Save'
      }
    },

    computed: {
      ...mapGetters(['recordsCount']),

      savingRecord: function(){
        const performedAt = this.record ? moment(this.currentRecord.performed_at) : moment()
        let savingRecord = Object.assign({}, this.currentRecord, { performed_at: performedAt },
                            { card_id: this.currentRecord.card.id })
        savingRecord.records_tags_attributes = savingRecord.records_tags.map(recTag => {
          delete recTag.tag
          return recTag
        })
        delete savingRecord.records_tags
        delete savingRecord.card
        delete savingRecord.card_name_old
        return savingRecord
      }
    },

    methods: {

      ...mapActions(['fetchRecords']),

      submitForm(e){
        e.preventDefault();

        if(this.currentRecord.id){
          this.updateExistingRecord();
        } else {
          this.createNewRecord();
        }
      },

      createNewRecord(){
        let _this = this;
        _this.saveButtonName = 'Saving...'

        axios.post('/records', { record: _this.savingRecord })
        .then((resp) => {
          _this.$emit("save");
          _this.fetchRecords()
        })
        .catch(err => console.log(err.response))
        .then(() => _this.saveButtonName = 'Save')
      },

      updateExistingRecord(){
        let _this = this;
        _this.saveButtonName = 'Updating...';

        axios.put(`/records/${_this.currentRecord.id}`, { record: _this.savingRecord })
          .then(res => {
            _this.fetchRecords({limit: this.recordsCount});
            _this.$emit("save");
          })
          .catch(err => console.log(err.response))
          .then(() => _this.saveButtonName = 'Update');
      },

      destroy() {
        const _this = this;

        axios.delete(`/records/${_this.record.id}`)
          .then(res => {
            _this.fetchRecords({limit: this.recordsCount});
            _this.$emit('save');
          })
          .catch(err => console.log(err.response));
      }
    }
  }
</script>
<style lang="css" scoped>
  .pure-form-message.pure-form-message-error {
    color: red;
  }
</style>

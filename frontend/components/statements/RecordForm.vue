<template>
  <form class="pure-form pure-form-stacked" v-on:submit="submitForm">
    <fieldset>
      <label for="record-name">Operation</label>
      <input type="text" id="record-name" placeholder="Enter operation" required v-model.trim="currentRecord.name">

      <label for="record-card">Card</label>

      <CardSelector
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
           v-on:click="$emit('destroy')"
           v-if="currentRecord.id"/>
  </form>
</template>
<script>
  import axios from 'axios'
  import moment from 'moment'
  import { mapActions } from 'vuex'
  import CardSelector from '../CardSelector.vue'

  const emptyNewRecord = () => {
    return {
      name: '',
      card: {},
      amount: 0.0,
      rest: 0.0,
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
    components: { CardSelector },

    props: ['record'],

    data: function(){
      return {
        currentRecord: initCurrentRecord(this.record),
        errors: [],
        saveButtonName: this.record ? 'Update' : 'Save'
      }
    },

    computed: {
      savingRecord: function(){
        const performedAt = this.record ? moment(this.currentRecord.performed_at) : moment()
        let savingRecord = Object.assign({}, this.currentRecord, { performed_at: performedAt },
                            { card_id: this.currentRecord.card.id })
        console.log(savingRecord);
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
        .then(function(resp){
          _this.$emit("save");
          _this.fetchRecords()
          Object.assign(_this.currentRecord, emptyNewRecord());
        })
        .catch(function(error){
          console.log(error.response)
        })
        .then(function(){
          _this.saveButtonName = 'Save'
        })
      },

      updateExistingRecord(){
        let _this = this;
        _this.saveButtonName = 'Updating...';
        axios.put(`/records/${_this.currentRecord.id}`, { record: _this.savingRecord }).then(function(res){
          _this.$emit("save");
          _this.fetchRecords()
        }).catch(function(error){
          console.log(error.response)
        }).then(function(){
          _this.saveButtonName = 'Update'
        });
      }
    }
  }
</script>
<style lang="css" scoped>
  .pure-form-message.pure-form-message-error {
    color: red;
  }
</style>

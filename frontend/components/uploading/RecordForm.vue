<template>
  <form class="pure-form pure-form-aligned" v-on:submit="submitForm">
    <fieldset>
      <legend>New Record Form</legend>
      <div class="pure-control-group">
        <label for="record-name">Operation</label>
        <input type="text" id="record-name" placeholder="Enter record name" required v-model.trim="newRecord.name">
        <span class="pure-form-message-inline"></span>
      </div>
      <div class="pure-control-group">
        <label for="record-card">Card</label>
        <input type="text" id="record-card" placeholder="Enter record card" v-model.trim="newRecord.card">
        <span class="pure-form-message-inline"></span>
      </div>
      <div class="pure-control-group">
        <label for="record-amount">Amount</label>
        <input type="number" id="record-amount" step="0.01" required v-model.number="newRecord.amount">
        <span class="pure-form-message-inline"></span>
      </div>
      <div class="pure-control-group">
        <label for="record-rest">Rest</label>
        <input type="number" id="record-rest" step="0.01" v-model.number="newRecord.rest">
        <span class="pure-form-message-inline"></span>
      </div>
      <div class="pure-control-group">
        <label for="record-performed-at">Performed At</label>
        <input type="datetime-local" id="record-performed-at" v-model="newRecord.performed_at">
        <span class="pure-form-message-inline"></span>
      </div>
      <div class="pure-controls">
        <input 
          type="submit"
          class="pure-button pure-button-primary"
          v-bind:value="saveButtonName"/>
      </div>
    </fieldset>
  </form>
</template>
<script>
  import axios from 'axios'
  import moment from 'moment'

  let emptyNewRecord = {
    name: '',
    card: '',
    amount: 0.0,
    rest: 0.0,
    performed_at: moment().format('YYYY-MM-DDTHH:mm')
  }

  export default {
    data: function(){
      return {
        newRecord: Object.assign({}, emptyNewRecord),
        errors: [],
        saveButtonName: 'Save'
      }
    },
    methods: {
      submitForm() {
        let _this = this;
        _this.saveButtonName = 'Saving...'
        axios.post('/records', { record: _this.newRecord })
          .then(function(resp){
            Object.assign(_this.newRecord, emptyNewRecord)
          })
          .catch(function(error){
            console.log(error.response)
          })
          .then(function(){
            _this.saveButtonName = 'Save'
          })
      }
    }
  }
</script>
<style lang="css" scoped>
  .pure-form-message.pure-form-message-error {
    color: red;
  }
</style>
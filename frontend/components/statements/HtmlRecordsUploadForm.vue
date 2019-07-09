<template>
  <form class="pure-form pure-form-stacked" v-on:submit="submitForm">
    <fieldset>
      <div class="pure-control-group">
        <label for="statements-html">Html table</label>
        <textarea id="statements-html"
                  placeholder="Past your statements html table"
                  v-bind:disabled="isDisabledTextArea"
                  v-model="htmlTable"/>
        <span class="pure-form-message pure-form-message-error" v-for="(errorMessage, index) in errors" v-if="errorMessage !== ''">
          {{ nubmerOfError === 1 ? errorMessage : `${index + 1} line - ${errorMessage}` }}
        </span>
      </div>
    </fieldset>
    <div class="pure-controls">
      <input type="submit" class="pure-button pure-button-primary" v-bind:value="saveButtonName">
    </div>
  </form>
</template>
<script>
  import axios from 'axios'
  import { mapActions } from 'vuex'

  export default {
    data: function(){
      return {
        htmlTable: '',
        errors: [],
        saveButtonName: 'Upload'
      }
    },

    computed: {
      isDisabledTextArea() { return this.saveButtonName !== 'Upload' },
      nubmerOfError() { return this.errors.length },
    },

    methods: {
      ...mapActions(['fetchRecords']),

      submitForm(){
        let _this = this;
        _this.errors = [];

        _this.saveButtonName = 'Parsing...';

        axios.post('/records/bulk/parse', { html_table: _this.htmlTable })
          .then(function(response){
            _this.saveButtonName = 'Validating...';
            console.log(response);

            axios.post('/records/bulk/validate', { records: response.data.records })
              .then(function(response){
                console.log(response);
                _this.saveButtonName = 'Saving...';

                axios.post('/records/bulk', { records: response.data.records })
                  .then(response => {
                    console.log(response);
                    _this.saveButtonName = 'Upload';
                    _this.htmlTable = '';
                    _this.fetchRecords();
                    _this.$emit('save');
                  })
                  .catch(error => _this.errorHandler(error.response));
              })
              .catch(error => _this.errorHandler(error.response));
          })
          .catch(error => _this.errorHandler(error.response));
      },

      errorHandler(response){
        console.log(response);
        this.saveButtonName = 'Upload';
        if(Array.isArray(response.data.message)) {
          this.errors = [...this.errors, ...response.data.message];
        } else {
          this.errors.push(response.data.message)
        }
      }
    }
  }
</script>
<style lang="css" scoped>
  .pure-form-message.pure-form-message-error {
    color: red;
  }
</style>

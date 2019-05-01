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
          <textarea id="statements-html"
                    placeholder="Past your statements html table"
                    v-bind:disabled="isDisabledTextArea"
                    v-model="htmlTable"/>
          <span class="pure-form-message pure-form-message-error" v-for="(errorMessage, index) in errors" v-if="errorMessage !== ''">
            {{ nubmerOfError === 1 ? errorMessage : `${index + 1} line - ${errorMessage}` }}
          </span>
        </fieldset>
        <input type="submit"
               class="pure-button pure-button-primary"
               v-bind:value="saveButtonName"
               v-on:click="saveStatements">
      </form>
    </div>
  </div>
</template>
<script>
  import axios from 'axios'

  export default {
    data: function(){
      return {
        htmlTable: '',
        errors: [],
        saveButtonName: 'Upload'
      }
    },
    computed: {
      isDisabledTextArea: function() { return this.saveButtonName !== 'Upload' },
      nubmerOfError: function() { return this.errors.length },
    },
    methods: {
      saveStatements: function(){
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
                  })
                  .catch(error => _this.errorHandler(error.response));
              })
              .catch(error => _this.errorHandler(error.response));
          })
          .catch(error => _this.errorHandler(error.response));
      },
      errorHandler: function(response){
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
  #statements-html{
    width: 100%;
    height: 15vw;
  }

  .pure-form-message.pure-form-message-error {
    color: red;
  }
</style>
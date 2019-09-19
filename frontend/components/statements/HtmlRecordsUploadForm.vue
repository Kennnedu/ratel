<template>
  <form class="pure-form pure-form-stacked" v-on:submit="submitForm">
    <fieldset>
      <div class="pure-control-group">
        <label for="statements-html">Html table</label>
        <input id="statements-html"
               type="file"
               placeholder="Past your statements html table"
               v-bind:disabled="isDisabledTextArea"
               v-on:change="e => { this.file = e.target.files[0] }"/>
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
        file: {},
        errors: [],
        saveButtonName: 'Upload'
      }
    },

    computed: {
      isDisabledTextArea() { return this.saveButtonName !== 'Upload' },
      nubmerOfError() { return this.errors.length },
    },

    methods: {
      ...mapActions(['fetchRecords', 'fetchCards']),

      submitForm(e){
        e.preventDefault();

        let _this = this;
        _this.errors = [];

        _this.saveButtonName = 'Saving...';

        axios.post('/records/bulk', this.getFormData())
          .then(res => {
            console.log(res);
            _this.saveButtonName = 'Upload';
            _this.fetchRecords();
            _this.fetchCards()
            _this.$emit('save');
          })
          .catch(err => _this.errorHandler(err.response));
      },

      errorHandler(response){
        console.log(response);
        this.saveButtonName = 'Upload';
        if(Array.isArray(response.data.message)) {
          this.errors = [...this.errors, ...response.data.message];
        } else {
          this.errors.push(response.data.message)
        }
      },

      getFormData() {
        let fd = new FormData();

        fd.append('html_file', this.file)

        return fd
      }
    }
  }
</script>
<style lang="css" scoped>
  .pure-form-message.pure-form-message-error {
    color: red;
  }
</style>

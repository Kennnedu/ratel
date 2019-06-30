<template>
  <div class="content">
    <button class="pure-button pure-button-primary add-new-record"
            v-on:click="isOpenNewRecordModal = true">
      + Add new Record
    </button>
    <h2>Total Records: {{ totalCount }}</h2>
    <RecordFetcher/>
    <div class="pure-g record-cards">
      <Record
        v-for="record in records"
        v-bind:key="record.id"
        v-bind:record="record"/>
    </div>
    <ModalWindow v-if='isOpenNewRecordModal' v-on:close='isOpenNewRecordModal = false'>
      <h3 slot="header">New Record</h3>
      <RecordForm
        slot='body'
        v-on:save='isOpenNewRecordModal = false'/>
    </ModalWindow>
  </div>
</template>
<script>
  import Record from './statements/Record.vue'
  import RecordFetcher from './statements/RecordFetcher.vue'
  import ModalWindow from './ModalWindow.vue'
  import RecordForm from './statements/RecordForm.vue'
  import moment from 'moment'
  import { mapState, mapGetters } from 'vuex';

  export default {
    components: { Record, RecordFetcher, ModalWindow, RecordForm },

    data: function() {
      return {
        isOpenNewRecordModal: false,
      }
    },

    computed: {
      ...mapState(['records']),
      ...mapGetters(['totalCount'])
    }
  }
</script>
<style lang="css">
  .record-cards {
    margin-top: 10px;
  }
  .add-new-record {
    float: right;
  }
</style>

<template>
  <div class="content">
    <h2>Total Records: {{ totalCount }}</h2>
    <h2>Total Sum: {{ totalSum }}</h2>
    <div class="pure-g record-cards">
      <Record
        v-for="record in records"
        v-bind:key="record.id"
        v-bind:record="record"/>
    </div>
  </div>
</template>
<script>
  import Record from './statements/Record.vue'
  import { mapState, mapGetters } from 'vuex';

  export default {
    components: { Record },

    data: function() {
      return {
        isOpenNewRecordModal: false,
      }
    },

    computed: {
      ...mapState(['records', 'totalSum']),
      ...mapGetters(['totalCount'])
    }
  }
</script>
<style lang="css">
  .record-cards {
    margin-top: 10px;
  }
</style>

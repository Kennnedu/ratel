<template>
  <div class="content">
    <h2>Total Records: {{ totalRecords }}</h2>
    <h2>Total Sum: {{ totalSum }}</h2>
    <div class="pure-g record-cards">
      <Record
        v-for="record in records"
        v-bind:key="record.id"
        v-bind:record="record"/>

      <div class="pure-u-1">
        <div class="show-more" v-if="totalRecords > recordsCount">
          <a v-on:click="e => this.fetchRecords(this.recordsCount + 30)">Show more...</a>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
  import Record from './statements/Record.vue'
  import { mapState, mapGetters, mapActions } from 'vuex';

  export default {
    components: { Record },

    data: function() {
      return {
        isOpenNewRecordModal: false,
      }
    },

    computed: {
      ...mapState(['records', 'totalSum', 'totalRecords']),
      ...mapGetters(['recordsCount'])
    },

    methods: {
      ...mapActions(['fetchRecords'])
    }
  }
</script>
<style lang="css">
  .record-cards, .show-more {
    margin-top: 10px;
  }

  .show-more {
    text-align: center;
  }

  .show-more a {
    cursor: pointer;
  }
</style>

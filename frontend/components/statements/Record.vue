<template>
  <div class="pure-u-1 pure-u-md-1-3">
    <div class="record-card"
         v-bind:class="{ positive: record.amount > 0 }">
      <div class="head">
        <span v-on:click="filterByTheName">
          {{ record.name }}
        </span>
      </div>
      <div class="body"
           v-on:click="isOpenEditDialog = true">
        <div class="tags">
          <span v-for="recordsTag in record.records_tags">{{recordsTag.tag.name}}</span>
        </div>
        <div class="card">{{ record.card.name }}</div>
        <div class="amount">{{ `${record.amount} BYN` }}</div>
        <div class="rest">{{ `${record.rest} BYN` }}</div>
        <div class="performed-at">{{ moment(record.performed_at).format('lll') }}</div>
      </div>
    </div>
    <ModalWindow v-if="isOpenEditDialog" v-on:close="isOpenEditDialog = false">
      <h3 slot="header">Edit {{record.name}} record</h3>
      <RecordForm slot="body" v-bind:record="record" v-on:destroy="destroy" v-on:save="hasChanges" />
    </ModalWindow>
  </div>
</template>
<script>
import moment from 'moment'
import axios from 'axios'
import ModalWindow from '../ModalWindow.vue'
import RecordForm from './RecordForm.vue'
import { mapActions, mapMutations, mapState } from 'vuex'

export default {
  components: { ModalWindow, RecordForm },

  props: ['record'],

  data: function(){
    return {
      moment: moment,
      isOpenEditDialog: false,
    }
  },

  methods: {

    ...mapActions(['fetchRecords']),

    ...mapMutations(['addFilteringName']),

    destroy(){
      let rec = this

      axios.delete(`/records/${rec.record.id}`).then(function(res){
        rec.hasChanges();
      }).catch(function(error){
        console.log(error)
      });
    },

    hasChanges(){
      this.isOpenEditDialog = false;
      this.fetchRecords();
    },

    filterByTheName() {
      this.addFilteringName({name: `!${this.record.name}`})
    }
  }

}
</script>
<style lang="css" scoped>
  .record-card {
    border: 1px solid #e0e0e0;
    border-radius: 7px;
    margin-right: 15px;
    margin-top: 15px;
  }

  .record-card .head {
    text-align: center;
  }

  .record-card .head span:hover {
    text-decoration: underline;
    cursor: pointer;
  }

  .record-card .body, .record-card .head {
    padding: 5px;
  }

  .record-card.positive {
    background-color: #ddfbdd;
  }

  .record-card:hover, .record-card:focus, .record-card:active {
    box-shadow: 0 0 10px rgba(0,0,0,0.5);
    transform: scale(1.04);
    transition: box-shadow 0.2s, transform 0.2s;
  }

  .record-card .body:hover {
    cursor: pointer;
  }

  .record-card .head, .record-card .body .amount {
    font-weight: bold;
  }

  .record-card .head, .record-card .body .card, .record-card .body .performed-at, .record-card .body .rest {
    font-size: 13px;
  }

  .tags span {
    font-size: 12px;
    background-color: #ababa9;
    padding: 3px;
    color: white;
    border-radius: 6px;
    margin-right: 3px;
  }
</style>

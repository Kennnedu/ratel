<template>
  <div class="pure-u-1 pure-u-md-1-3">
    <div class="record-card">
      <div class="head">
        <span
          v-on:click="$emit('addFilteringName', `!${record.name}`)">
          {{ record.name }}
        </span>
      </div>
      <div class="body"
           v-bind:class="{ positive: record.amount > 0 }"
           v-on:click="isOpenEditDialog = true">
        <div class="card">{{ record.card }}</div>
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
      this.$emit("hasChanges");
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
    border-bottom: 1px solid #e0e0e0;
  }

  .record-card .head span:hover {
    text-decoration: underline;
    cursor: pointer;
  }

  .record-card .body, .record-card .head {
    padding: 5px;
  }

  .record-card .body.positive {
    background-color: #ddfbdd;
  }

  .record-card .body.positive:hover {
    background-color: #a7f592;
  }

  .record-card .body:hover {
    background-color: #e0e0e0;
    cursor: pointer;
  }

  .record-card .head, .record-card .body .amount {
    font-weight: bold;
  }

  .record-card .head, .record-card .body .card, .record-card .body .performed-at, .record-card .body .rest {
    font-size: 13px;
  }
</style>

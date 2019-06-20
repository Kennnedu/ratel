<template>
  <div class="pure-u-1 pure-u-md-1-3">
    <div class="record-card" v-bind:class="{ positive: record.amount > 0 }"
         v-on:click="isOpenEditDialog = true">
      <div class="name">{{ record.name }}</div>
      <div class="card">{{ record.card }}</div>
      <div class="amount">{{ `${record.amount} BYN` }}</div>
      <div class="rest">{{ `${record.rest} BYN` }}</div>
      <div class="performed-at">{{ moment(record.performed_at).format('lll') }}</div>
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
  .fa-edit:hover, .fa-trash-alt:hover {
    cursor: pointer;
  }

  .fa-edit {
    margin-right: 5px;
  }

  .record-card {
    border: 1px solid #e0e0e0;
    padding: 5px;
    border-radius: 7px;
    margin-right: 15px;
    margin-top: 15px;
  }

  .record-card .actions {
    float: right;
  }

  .record-card.positive {
    background-color: #ddfbdd;
  }

  .record-card.positive:hover {
    background-color: #a7f592;
  }

  .record-card:hover {
    background-color: #e0e0e0;
    cursor: pointer;
  }

  .record-card .name, .record-card .amount {
    font-weight: bold;
  }

  .record-card .name, .record-card .card, .record-card .performed-at, .record-card .rest {
    font-size: 13px;
  }
</style>

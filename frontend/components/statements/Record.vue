<template>
  <div class="pure-u-1 pure-u-md-1-3">
    <div class="record-card" v-bind:class="{ positive: record.amount > 0 }">
      <div class="actions">
        <font-awesome-icon icon="trash-alt" v-on:click="destroy" />
      </div>
      <div class="name">{{ record.name }}</div>
      <div class="card">{{ record.card }}</div>
      <div class="amount">{{ `${record.amount} BYN` }}</div>
      <div class="rest">{{ `${record.rest} BYN` }}</div>
      <div class="performed-at">{{ moment(record.performed_at).format('lll') }}</div>
    </div>
  </div>
</template>
<script>
import moment from 'moment'
import axios from 'axios'

export default {
  props: ['record'],
  data: function(){
    return {
      moment: moment
    }
  },
  methods: {
    destroy(){
      let rec = this

      axios.delete(`/records/${rec.record.id}`).then(function(res){
        rec.$emit("destroy", rec.record.id)
      }).catch(function(error){
        console.log(error)
      });
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

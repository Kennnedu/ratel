<template>
  <tr>
    <td>{{ record.name }}</td>
    <td>{{ record.card }}</td>
    <td>{{ `${record.amount} BYN` }}</td>
    <td>{{ `${record.rest} BYN` }}</td>
    <td>{{ moment(record.performed_at).format('lll') }}</td>
    <td>
      <font-awesome-icon icon="trash-alt" v-on:click="destroy" />
    </td>
  </tr>
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
</style>

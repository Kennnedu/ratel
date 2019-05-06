<template>
  <tr>
    <td>{{ record.name }}</td>
    <td>{{ record.card }}</td>
    <td>{{ `${record.amount} BYN` }}</td>
    <td>{{ `${record.rest} BYN` }}</td>
    <td>{{ moment(record.performed_at).format('lll') }}</td>
  </tr>
</template>
<script>
import moment from 'moment'

export default {
  props: ['record'],
  data: function(){
    return {
      moment: moment
    }
  }
}
</script>

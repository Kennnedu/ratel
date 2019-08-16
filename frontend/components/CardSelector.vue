<template>
  <select
    v-bind:required="required"
    v-model="currentCardId"
    v-on:change="$emit('selectCard', cards.filter(card => currentCardId === card.id)[0])">
    <option
      v-for="card in cards"
      v-bind:key="card.id"
      v-bind:value="card.id"
      v-bind:selected="currentCardId === card.id">
      {{card.name}}
    </option>
  </select>
</template>
<script>
import { mapState } from 'vuex'

export default {
  props: ['card', 'required'],

  data: function(){
    return {
      currentCardId: this.card.id || null,
    }
  },

  computed: {
    ...mapState(['cards'])
  }
}
</script>
<style lang="css" scoped>
</style>

<template>
  <div>
    <!-- <input
      type="text"
      placeholder="Press space to add new tag"
      list="suggested-tags"
      v-model="tagName"
      v-on:keyup.space="addRecordsTag" />
 -->
    <label for="record-name">Operation</label>
    <input
      type="text"
      id="record-name"
      placeholder="Enter operation"
      v-model.trim="currentRecord.name"
      required />

    <datalist id="suggested-record-names">
      <option v-for="recName in suggestedRecordNames" v-bind:key="recName" v-bind:value="recName" />
    </datalist>
  </div>
</template>
<script>
import axios from 'axios'

export default {
  props: ['recordName'],

  data: function(){
    return {
      suggestedRecordNames: []
    }
  },

  watch: {

  }
}
</script>
<style lang="css" scoped>
  .tags span {
    font-size: 13px;
    background-color: #ababa9;
    padding: 3px;
    color: white;
    border-radius: 6px;
    margin-right: 3px;
  }

  .tags span svg {
    margin-left: 2px;
  }
</style>

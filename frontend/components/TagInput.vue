<template>
  <div>
    <div>
      <span v-for="tag"></span>
    </div>
    <input
      type="string"
      placeholder="Press 'space' to add new tag"
      v-on:keyup.space="" />
    <ul>
      <option v-for="tag in prefetchedTags" v-bind:key="tag.id"></option>
    </ul>
  </div>
</template>
<script>
import axios from 'axios'

export default {
  props: ['tags'],

  data: function(){
    return {
      // currentCardId: this.card.id || null,
      prefetchedTags: []
    }
  },

  methods: {
    addTag(tag){
      if(!tag.id) findOrCreateTag()

      this.$emit('addTag', tag)
    },

    findOrCreateTag(tag){
    },

    fetchTagsLike(name){
    }
  }
}
</script>
<style lang="css" scoped>
</style>

<template>
  <div>
    <div class="tags">
      <span v-for="recordsTag in recordsTags.filter(recTag => !recTag._destroy)">
        {{recordsTag.tag.name}}
        <font-awesome-icon
          prefix="far"
          icon="times-circle"
          v-on:click="e => deleteRecordsTag(recordsTag)" />
      </span>
    </div>
    <input
      type="text"
      placeholder="Press space to add new tag"
      v-model="tagName"
      v-on:keyup.space="addRecordsTag" />
  </div>
</template>
<script>
import axios from 'axios'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faTimesCircle } from '@fortawesome/free-solid-svg-icons'

library.add(faTimesCircle)

export default {
  props: ['recordsTags'],

  data: function(){
    return {
      tagName: ''
    }
  },

  computed: {
    displayingRecordsTags() {
      return this.recordsTags.filter(recTag => !recTag._destroy)
    }
  },

  methods: {
    addRecordsTag(){
      const _this = this;

      axios.post(`/tags/${_this.tagName}`)
        .then(resp => {
          _this.tagName = "";
          _this.$emit('change', [..._this.recordsTags, ...[Object.assign({tag_id: resp.data.tag.id}, resp.data)] ]);
        })
        .catch(error => console.log(error.error))
    },

    deleteRecordsTag(removingRecordsTag) {
      if(removingRecordsTag.id) {
        removingRecordsTag._destroy = true
        this.$emit('change', [...[], ...this.recordsTags])
      } else this.$emit('change', this.recordsTags.filter(recTag => recTag.tag_id !== removingRecordsTag.tag_id))
    }
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

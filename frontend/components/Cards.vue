<template>
  <div class="content">
    <div class="pure-g">
      <div class="pure-u-1">
        <h2>Cards</h2>
        <button class="pure-button pure-button-primary new-card-button">
          <font-awesome-icon icon="plus" />
          New card
        </button>
      </div>
      <div class="pure-u-1">
        <table class="pure-table pure-table-horizontal">
          <thead>
            <tr>
              <th>Name</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="card in cards">
              <td>{{card.name}}</td>
              <td class="actions">
                <div>
                  <button class="pure-button">Edit</button>
                  <button class="pure-button button-error">Delete</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
<script>
import { mapState } from 'vuex'
import { faPlus } from '@fortawesome/free-solid-svg-icons'
import { library } from '@fortawesome/fontawesome-svg-core'

library.add(faPlus)

export default {
  computed: {
    ...mapState(['cards'])
  }
}
</script>
<style lang="css" scoped>
  table {
    margin-top: 5px;
  }

  td.actions div, .new-card-button {
    float: right;
  }
</style>

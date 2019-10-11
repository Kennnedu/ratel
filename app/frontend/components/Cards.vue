<template>
  <div class="content">
    <div class="pure-g">
      <div class="pure-u-1">
        <h2>Cards</h2>
      </div>
      <div class="pure-u-1">
        <a
          href="#"
          class="pure-button pure-button-primary new-card-btn"
          v-on:click="() => openingCardModal({name: ''})">
          <font-awesome-icon icon="plus" />
          New card
        </a>
        <table class="pure-table pure-table-horizontal">
          <tbody>
            <tr v-for="card in cards">
              <td>
                <a href="#" v-on:click="() => openingCardModal(card)">
                  {{card.name}}
                </a>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <ModalWindow v-if='isOpenCardModal' v-on:close='isOpenCardModal = false'>
      <h3 slot="header">
        {{
          selectedCard.id ? `Edit ${selectedCard.name} card`  : 'New card'
        }}
      </h3>
      <CardForm
        slot='body'
        v-bind:card="selectedCard"
        v-on:close='isOpenCardModal = false'/>
    </ModalWindow>
  </div>
</template>
<script>
import { mapState } from 'vuex'
import { faPlus } from '@fortawesome/free-solid-svg-icons'
import { library } from '@fortawesome/fontawesome-svg-core'
import CardForm from './CardForm.vue'
import ModalWindow from './ModalWindow.vue'

library.add(faPlus)

export default {
  components: {
    CardForm,
    ModalWindow
  },

  computed: {
    ...mapState(['cards'])
  },

  data: function(){
    return {
      selectedCard: {name: ''},
      isOpenCardModal: false
    }
  },

  methods: {
    openingCardModal(card) {
      this.selectedCard = card
      this.isOpenCardModal = true
    }
  }
}
</script>
<style lang="css" scoped>
  .new-card-btn {
    width: inherit;
  }

  td a {
    color: #777;
  }

</style>

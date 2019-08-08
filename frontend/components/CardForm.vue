<template>
  <form class="pure-form pure-form-stacked" v-on:submit="submitForm">
    <fieldset>
      <label for="card-name">Name</label>
      <input type="text" id="card-name" placeholder="Enter card name" v-model="currentCard.name" required>
    </fieldset>

    <input type="submit" v-bind:value="saveButtonName" class="pure-button pure-button-primary">
    <input type="button"
           value="Delete"
           v-if="currentCard.id"
           class="pure-button button-error"
           v-on:click="deleteCard">
  </form>
</template>
<script>
import { mapState, mapActions } from 'vuex'
import axios from 'axios'

export default {
  props: ['card'],

  data: function(){
    return {
      currentCard: Object.assign({}, this.card),
      saveButtonName: this.card.id ? "Update" : "Create"
    }
  },

  computed: {
    savingCard() {
      let savingCard = this.currentCard
      delete savingCard.id
      return { card: savingCard }
    }
  },

  methods: {
    ...mapActions(['fetchCards', 'fetchRecords']),

    submitForm(e){
      e.preventDefault();

      if(!this.currentCard.id) this.createCard()
      else this.updateCard()
    },

    createCard(){
      const _this = this

      axios.post('/cards', _this.savingCard)
      .then(resp => {
        _this.fetchCards();
        _this.$emit('close');
      })
      .catch(error => console.log(error.response))
      .then(() => _this.$emit('close'));
    },

    updateCard(){
      const _this = this

      axios.put(`/cards/${_this.currentCard.id}`, _this.savingCard)
      .then(resp => {
        _this.fetchCards();
        _this.$emit('close');
      })
      .catch(error => console.log(error.response))
      .then(() => _this.$emit('close'))
    },

    deleteCard(e){
      e.preventDefault();
      const _this = this

      axios.delete(`/cards/${_this.currentCard.id}`)
      .then(resp => {
        _this.fetchCards();
        _this.fetchRecords();
        _this.$emit('close');
      })
      .catch(error => console.log(error.response))
      .then(() => _this.$emit('close'));
    }
  }
}
</script>
<style lang="css" scoped>
</style>

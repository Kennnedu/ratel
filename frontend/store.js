import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'
import moment from 'moment'

Vue.use(Vuex)

const defaultFilter = {
  name: "",
  card: "",
  from: moment().set('year', moment().get('year') - 1).format('YYYY-MM-DD'),
  to: moment().format('YYYY-MM-DD')
}

export default new Vuex.Store({
  state: {
    records: [],
    totalSum: 0,
    totalRecords: 0,
    filter: defaultFilter,
    cards: []
  },

  getters: {
    recordsCount: state => {
      return state.records.length
    }
  },

  mutations: {
    updateRecords(state, payload) {
      state.records = payload.records
    },

    updateTotalRecords(state, payload) {
      state.totalRecords = payload.totalRecords
    },

    updateCards(state, payload) {
      state.cards = payload.cards
    },

    updateTotalSum(state, payload) {
      state.totalSum = payload.totalSum
    },

    updateFilter(state, payload) {
      state.filter = Object.assign({}, state.filter, payload.changes)
    },

    resetFilter(state) {
      state.filter = defaultFilter
    },

    addFilteringName(state, payload) {
      state.filter.name = `${state.filter.name}&${payload.name}`
    }
  },

  actions: {
    fetchRecords({ commit, state }, offset){
      return new Promise((resolve, reject) => {
        axios.get('/records', { params: Object.assign({}, state.filter, { offset: offset})})
        .then(data => {
          commit('updateRecords', { records: data.data.records });
          commit('updateTotalSum', { totalSum: data.data.total_sum });
          commit('updateTotalRecords', { totalRecords: data.data.total_count })
          resolve();
        })
        .catch(error => {
          console.log(error.response);
          reject(error.response);
        })
      })
    },

    fetchCards(context){
      return new Promise((resolve, reject) => {
        axios.get('/cards').then(data => {
          context.commit('updateCards', data.data);
          resolve();
        })
        .catch(error => {
          console.log(error.response);
          reject(error.response);
        })
      })
    }
  }
})

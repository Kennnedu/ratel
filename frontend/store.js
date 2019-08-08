import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'
import moment from 'moment'

Vue.use(Vuex)

const defaultFilter = {
  name: "",
  card: "",
  from: moment().set('month', moment().get('month') - 1).format('YYYY-MM-DD'),
  to: moment().format('YYYY-MM-DD')
}

export default new Vuex.Store({
  state: {
    records: [],
    totalSum: 0,
    filter: defaultFilter,
    dashboardData: {
      cardsData: [],
      expencesData: [],
      replenishmentsData: []
    },
    cards: []
  },

  getters: {
    totalCount: state => {
      return state.records.length
    }
  },

  mutations: {
    updateRecords(state, payload) {
      state.records = payload.records
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
    },

    updateDashboardData(state, payload) {
      state.dashboardData = payload
    }
  },

  actions: {
    fetchRecords(context){
      return new Promise((resolve, reject) => {
        axios.get('/records', { params: context.state.filter})
        .then(data => {
          context.commit('updateRecords', { records: data.data.records });
          context.commit('updateTotalSum', { totalSum: data.data.total_sum });
          context.commit('updateDashboardData', {
            cardsData: data.data.cards_data,
            expencesData: data.data.expences_data,
            replenishmentsData: data.data.replenishments_data
          })
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

import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'
import moment from 'moment'

Vue.use(Vuex)

function initializeFilter(){
  const savedFilter = JSON.parse(localStorage.getItem('defaultFilter'));
  if(savedFilter) return savedFilter;
  return {
    name: "",
    card: "",
    from: moment().set('year', moment().get('year') - 1).format('YYYY-MM-DD'),
    to: moment().format('YYYY-MM-DD')
  }
}

export default new Vuex.Store({
  state: {
    records: [],
    totalSum: 0,
    totalRecords: 0,
    filter: initializeFilter(),
    cards: []
  },

  getters: {
    recordsCount: state => {
      return state.records.length
    },

    filterParams: state => {
      return {
        name: state.filter.name,
        card: state.filter.card,
        from: moment(state.filter.from).utc().format('llll'),
        to: moment(state.filter.to).utc().format('llll'),
        limit: 32
      }
    }
  },

  mutations: {
    addRecords(state, payload) {
      state.records = [...state.records, ...payload.records]
    },

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

    addFilteringName(state, payload) {
      state.filter.name = `${state.filter.name}&${payload.name}`
    }
  },

  actions: {
    fetchRecords({ commit, getters }, params){
      !params && (params = {});
      return new Promise((resolve, reject) => {
        axios.get('/records', { params: Object.assign({}, getters.filterParams, params) })
        .then(data => {
          if(params.offset){
            commit('addRecords', { records: data.data.records });
          }
          else {
            commit('updateRecords', { records: data.data.records });
            commit('updateTotalSum', { totalSum: data.data.total_sum });
            commit('updateTotalRecords', { totalRecords: data.data.total_count })
          }

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

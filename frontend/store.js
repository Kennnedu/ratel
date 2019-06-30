import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    records: [],
    totalSum: 0
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

    updateTotalSum(state, payload) {
      state.totalSum = payload.totalSum
    }
  },

  actions: {
    fetchRecords(context, filter){
      return new Promise((resolve, reject) => {
        axios.get('/records', { params: filter})
        .then(function(data){
          context.commit('updateRecords', { records: data.data.records });
          context.commit('updateTotalSum', { totalSum: data.data.total_sum });
          resolve();
        })
        .catch(function(error){
          console.log(error.response);
          reject(error.response);
        })
      })
    }
  }
})

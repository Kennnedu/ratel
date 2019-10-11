import 'purecss'
import './stylesheets/responsive_grid.css'
import Vue from 'vue'
import store from './store.js'
import RatelApp from './RatelApp.vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

Vue.component('font-awesome-icon', FontAwesomeIcon)

Vue.config.productionTip = false

window.onload = function(){
  new Vue({
    el: '#ratel-app',
    store,
    render: createElement => createElement(RatelApp)
  });
}

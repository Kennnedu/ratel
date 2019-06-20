import 'purecss'
import './stylesheets/pure_responsive_grid.css'
import Vue from 'vue'
import RatelApp from './RatelApp.vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

Vue.component('font-awesome-icon', FontAwesomeIcon)

Vue.config.productionTip = false

window.onload = function(){
  new Vue({
    el: '#ratel-app',
    render: createElement => createElement(RatelApp)
  });
}

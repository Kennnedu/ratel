import 'purecss'
import Vue from 'vue'
import RatelApp from './RatelApp.vue'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faTrashAlt, faEdit } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

library.add(faEdit, faTrashAlt)

Vue.component('font-awesome-icon', FontAwesomeIcon)

Vue.config.productionTip = false

window.onload = function(){
  new Vue({
    el: '#ratel-app',
    render: createElement => createElement(RatelApp)
  });
}

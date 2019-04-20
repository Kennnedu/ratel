import 'purecss'
import Vue from 'vue'
import RatelApp from './RatelApp.vue'

Vue.config.productionTip = false

window.onload = function(){
  new Vue({
    el: '#ratel-app',
    render: createElement => createElement(RatelApp)
  });
}

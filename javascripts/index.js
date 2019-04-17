import Vue from 'vue'
import RatelApp from './RatelApp.vue'

window.onload = function(){
  new Vue({
    el: '#ratel-app',
    render: createElement => createElement(RatelApp)
  });
}

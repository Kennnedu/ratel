<template>
  <div id="layout" v-bind:class="{active: active}">
    <a href="#menu"
       id="menuLink"
       class="menu-link"
       v-on:click="active = !active"
       v-bind:class="{active: active}">
      <span></span>
    </a>
    <div id="menu" v-bind:class="{active: active}">
      <div class="pure-menu">
        <a class="pure-menu-heading" href="#">Ratel</a>
        <ul class="pure-menu-list">
          <li
            class="pure-menu-item"
            v-for="page in navigationMenuPages"
            v-bind:class="{'pure-menu-selected': currentPage === page,
                           'menu-item-divided': navigationMenuPages[0] === page}">
            <a href="#"
               class="pure-menu-link"
               v-on:click="$emit('navigateTo', page)">
              {{page}}
              <span
                class="total-sum"
                v-bind:class="{'positive': parseFloat(totalSum) > 0, 'negative': parseFloat(totalSum) < 0}"
                v-if="page === 'Records'">
                {{totalSum}}
              </span>
            </a>
          </li>
        </ul>
      </div>
    </div>
    <div id="main" v-on:click="active ? active = false : false">
      <slot></slot>
    </div>
  </div>
</template>

<script>
  import '../stylesheets/navigation.css'
  import { mapState } from 'vuex'

  export default {
    props: ['currentPage'],

    data: function(){
      return {
        active: false,
        navigationMenuPages: ['Uploading', 'Dashboard', 'Records'],
      }
    },

    computed: {
      ...mapState(['totalSum'])
    }
  }
</script>

<style lang="css">
  span.total-sum {
    font-size: 12px;
  }

  span.total-sum.positive {
    color: #a0f8a0
  }

  span.total-sum.negative {
    color: #ff5b5b
  }
</style>

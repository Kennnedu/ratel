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
          <li class="pure-menu-item"
              v-for="page in navigationMenu"
              v-bind:class="{'menu-item-divided pure-menu-selected': currentPage === page}">
            <a href="#"
               class="pure-menu-link"
               v-on:click="$emit('navigateTo', page)">
              {{page}}
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
  import './layout.css'

  export default {
    props: ['currentPage'],
    data: function(){
      return {
        active: false,
        navigationMenu: ['Dashboard', 'Uploading', 'Statements']
      }
    }
  }
</script>

<style lang="css">
</style>

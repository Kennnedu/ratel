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
          <li class="pure-menu-item">
            <a href="#" class="pure-menu-link" v-on:click="isOpenNewRecordModal = true">
              + Add record
            </a>
          </li>
          <li class="pure-menu-item">
            <a href="#" class="pure-menu-link" v-on:click="isOpenHtmlRecordsUploadModal = true">
              Upload Records
            </a>
          </li>
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
                v-if="page === 'State'">
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
    <ModalWindow v-if='isOpenNewRecordModal' v-on:close='isOpenNewRecordModal = false'>
      <h3 slot="header">New Record</h3>
      <RecordForm
        slot='body'
        v-on:save='isOpenNewRecordModal = false'/>
    </ModalWindow>
    <ModalWindow v-if='isOpenHtmlRecordsUploadModal' v-on:close='isOpenHtmlRecordsUploadModal = false'>
      <h3 slot="header">Upload records(html table)</h3>
      <HtmlRecordsUploadForm
        slot='body'
        v-on:save='isOpenHtmlRecordsUploadModal = false'/>
    </ModalWindow>
  </div>
</template>

<script>
  import '../stylesheets/navigation.css'
  import ModalWindow from './ModalWindow.vue'
  import RecordForm from './statements/RecordForm.vue'
  import HtmlRecordsUploadForm from './statements/HtmlRecordsUploadForm.vue'
  import { mapState } from 'vuex'

  export default {
    components: { ModalWindow, RecordForm, HtmlRecordsUploadForm },

    props: ['currentPage'],

    data: function(){
      return {
        active: false,
        navigationMenuPages: ['State', 'Dashboard'],
        isOpenNewRecordModal: false,
        isOpenHtmlRecordsUploadModal: false
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

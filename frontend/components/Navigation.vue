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
              <font-awesome-icon icon="plus" /> New record
            </a>
          </li>
          <li class="pure-menu-item">
            <a href="#" class="pure-menu-link" v-on:click="isOpenRecordFilterModal = true">
              <font-awesome-icon icon="filter" /> Filtering
            </a>
          </li>
          <li class="pure-menu-item">
            <a href="#" class="pure-menu-link" v-on:click="isOpenHtmlRecordsUploadModal = true">
              <font-awesome-icon icon="upload" /> Uploading
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
              <font-awesome-icon icon="tachometer-alt" v-if="page==='Dashboard'" /> {{page}}
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
    <ModalWindow v-if='isOpenRecordFilterModal' v-on:close='isOpenRecordFilterModal = false'>
      <h3 slot="header">Filter records</h3>
      <RecordFilter
        slot='body'
        v-on:close='isOpenRecordFilterModal = false'/>
    </ModalWindow>
  </div>
</template>

<script>
  import '../stylesheets/navigation.css'
  import ModalWindow from './ModalWindow.vue'
  import RecordForm from './statements/RecordForm.vue'
  import RecordFilter from './statements/RecordFilter.vue'
  import HtmlRecordsUploadForm from './statements/HtmlRecordsUploadForm.vue'
  import { library } from '@fortawesome/fontawesome-svg-core'
  import { faUpload, faPlus, faFilter, faTachometerAlt } from '@fortawesome/free-solid-svg-icons'
  import { mapState, mapActions } from 'vuex'

  library.add(faUpload, faPlus, faFilter, faTachometerAlt)

  export default {
    components: { ModalWindow, RecordForm, HtmlRecordsUploadForm, RecordFilter },

    props: ['currentPage'],

    data: function(){
      return {
        active: false,
        navigationMenuPages: ['Dashboard', 'State'],
        isOpenNewRecordModal: false,
        isOpenRecordFilterModal: false,
        isOpenHtmlRecordsUploadModal: false
      }
    },

    mounted() {
      this.debouncedFetchRecords = _.debounce(this.fetchRecords, 500);
      this.fetchRecords()
    },

    computed: {
      ...mapState(['totalSum', 'filter'])
    },

    watch: {
      filter: {
        handler: function(){
          this.debouncedFetchRecords()
        },
        deep: true
      },
    },

    methods: {
      ...mapActions(['fetchRecords'])
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

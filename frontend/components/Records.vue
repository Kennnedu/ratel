<template>
  <section id="content">
    <nav class="navigation">
      <button class="pure-button" v-on:click="isOpenRecordFilterModal = true">
        <font-awesome-icon icon="filter" style="color: #777" />
      </button>
      <button class="pure-button" v-on:click="isOpenRecordBatchFormModal = true">
        <font-awesome-icon icon="edit" style="color: #777" />
      </button>
      <span></span>
      <button
        class="pure-button pure-button-primary"
        v-on:click="$emit('navigateTo', 'Dashboard')">
        Group by
      </button>
      <a href="#"
         class="pure-button pure-button-primary button-scroll-back"
         v-if="displayBackButton"
         v-on:click="scrollBack">
        <font-awesome-icon icon="arrow-up" />
        Back
      </a>
    </nav>
    <main class="records" v-bind:touchmove="e => { e.preventDefault(); return null }" v-on:scroll="recordsScroll">
      <section id="new-records">
        <font-awesome-icon icon="plus" size="4x" style="color: #ababa9"
          v-on:click="isOpenNewRecordModal = true" />
        <font-awesome-icon icon="upload" size="3x" style="color: #ababa9"
          v-on:click="isOpenHtmlRecordsUploadModal = true" />
      </section>
      <template v-for="(record, index) in records">
        <section
          class="divide-date"
          v-if="index === 0 || (index !== 0 && !moment(record.performed_at).isSame(records[index-1].performed_at, 'day'))">
          <em>{{ moment(record.performed_at).format('LL') }}</em>
        </section>
        <Record
          v-bind:key="record.id"
          v-bind:record="record"
          v-on:click="currentRecord = record; isOpenEditDialog = true"/>
      </template>
    </main>
    <ModalWindow v-if='isOpenNewRecordModal' v-on:close='isOpenNewRecordModal = false'>
      <h3 slot="header">New Record</h3>
      <RecordForm
        slot='body'
        v-on:save='isOpenNewRecordModal = false'/>
    </ModalWindow>
    <ModalWindow v-if="isOpenEditDialog" v-on:close="isOpenEditDialog = false">
      <h3 slot="header">Edit {{currentRecord.name}} record</h3>
      <RecordForm slot="body" v-bind:record="currentRecord" v-on:save="isOpenEditDialog = false" />
    </ModalWindow>
    <ModalWindow v-if='isOpenRecordFilterModal' v-on:close='isOpenRecordFilterModal = false'>
      <h3 slot="header">Filter records</h3>
      <RecordFilter
        slot='body'
        v-on:close='isOpenRecordFilterModal = false'/>
    </ModalWindow>
    <ModalWindow v-if="isOpenRecordBatchFormModal" v-on:close='isOpenRecordBatchFormModal = false'>
      <h3 slot="header">Edit filtered records</h3>
      <RecordBatchForm
        slot='body'
        v-on:close='isOpenRecordBatchFormModal = false'/>
    </ModalWindow>
    <ModalWindow v-if='isOpenHtmlRecordsUploadModal' v-on:close='isOpenHtmlRecordsUploadModal = false'>
      <h3 slot="header">Upload records(html table)</h3>
      <HtmlRecordsUploadForm
        slot='body'
        v-on:save='isOpenHtmlRecordsUploadModal = false'/>
    </ModalWindow>
  </section>
</template>
<script>
  import Record from './statements/Record.vue'
  import ModalWindow from './ModalWindow.vue'
  import RecordForm from './statements/RecordForm.vue'
  import RecordFilter from './statements/RecordFilter.vue'
  import RecordBatchForm from './statements/RecordBatchForm.vue'
  import HtmlRecordsUploadForm from './statements/HtmlRecordsUploadForm.vue'
  import moment from 'moment'
  import { mapState, mapGetters, mapActions } from 'vuex'
  import { library } from '@fortawesome/fontawesome-svg-core'
  import { faUpload, faPlus, faFilter, faEdit, faArrowUp } from '@fortawesome/free-solid-svg-icons'

  library.add(faUpload, faPlus, faFilter, faEdit, faArrowUp)

  export default {
    components: { Record, ModalWindow, RecordForm, RecordFilter, RecordBatchForm, HtmlRecordsUploadForm },

    data: function() {
      return {
        isOpenHtmlRecordsUploadModal: false,
        isOpenRecordBatchFormModal: false,
        isOpenRecordFilterModal: false,
        isOpenNewRecordModal: false,
        isOpenEditDialog: false,
        isFetchingRecords: false,
        displayBackButton: false,
        currentRecord: {},
        moment: moment
      }
    },

    mounted() {
      this.fetchRecords();
      this.fetchCards();
    },

    computed: {
      ...mapState(['records', 'totalSum', 'totalRecords']),
      ...mapGetters(['recordsCount'])
    },

    watch: {
      recordsCount() {
        if(this.isFetchingRecords) this.isFetchingRecords = false
      }
    },

    methods: {
      ...mapActions(['fetchRecords', 'fetchCards']),

      recordsScroll(e) {
        e.preventDefault();

        const elem = e.target

        if((elem.scrollTop + 900) > elem.scrollHeight && !this.isFetchingRecords && this.recordsCount < this.totalRecords) {
          this.isFetchingRecords = true
          this.fetchRecords(this.recordsCount);
        }

        if(elem.scrollTop < 30 && this.displayBackButton) this.displayBackButton = false
        else if(elem.scrollTop > 30 && !this.displayBackButton) this.displayBackButton = true
      },

      reduceScroll(elem) {
        if(elem.scrollTop === 0) return null
        elem.scrollTop -= Math.max(100, Math.floor(elem.scrollTop / 10));
        setTimeout(() => this.reduceScroll(elem), 30);
      },

      scrollBack(e){
      e.preventDefault();

        this.reduceScroll(document.querySelector('.records'));
        this.displayBackButton = false;
      }
    }
  }
</script>
<style lang="css" scoped>
  .navigation {
    position: relative;
    padding: 0 20px 5px 20px;
    display: grid;
    grid-template-columns: 1fr 1fr 4fr 1fr;
    grid-gap: 5px;
  }

  .records {
    height: calc(100vh - 20vh);
    overflow-y: scroll;
    -webkit-overflow-scrolling: touch;
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    grid-template-rows: 185px;
    grid-gap: 15px;
    padding: 20px 20px 10px 20px
  }

  #new-records {
    border: 3px dashed #e0e0e0;
    border-radius: 7px;
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-template-rows: 100%;
  }

  #new-records svg {
    cursor: pointer;
    align-self: center;
    justify-self: center;
  }

  .button-scroll-back {
    position: absolute;
    top: 7vh;
    right: 42%;
    z-index: 2;
    border-radius: 20px;
  }

  .divide-date {
    position: relative;
    grid-column-start: 1;
    grid-column-end: 4;
    text-align: center;
  }

  .divide-date:after {
    content: "";
    position: absolute;
    bottom: 0;
    left: 65%;
    right: 0;
    height: 0.5em;
    border-top: 2px solid #e0e0e0;
    z-index: -1;
    width: 35%;
  }

  .divide-date:before {
    content: "";
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 0.5em;
    border-top: 2px solid #e0e0e0;
    z-index: -1;
    width: 35%;
  }

  @media (max-width: 1024px) {
    .records {
      height: calc(100vh - 15vh);
      grid-template-columns: 100%;
    }

    #new-records {
      grid-template-columns: 100%;
    }

    #new-records svg:last-child {
      display: none;
    }

    .divide-date {
      grid-column-start: 1;
      grid-column-end: 2;
      text-align: center;
    }

    .divide-date:before {
      width: 20%;
    }

    .divide-date:after {
      left: 80%;
      width: 20%;
    }

    @supports (-webkit-overflow-scrolling: touch) {
      .records {
        height: calc(100vh - 30vh);
      }
    }
  }
</style>

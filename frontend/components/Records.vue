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
    </nav>
    <main class="records" v-bind:touchmove="e => { e.preventDefault(); return null }">
        <section class="new-records">
          <font-awesome-icon icon="plus" size="4x" style="color: #ababa9"
            v-on:click="isOpenNewRecordModal = true" />
          <font-awesome-icon icon="upload" size="3x" style="color: #ababa9"
            v-on:click="isOpenHtmlRecordsUploadModal = true" />
        </section>
        <Record
          v-for="record in records"
          v-bind:key="record.id"
          v-bind:record="record"
          v-on:click="currentRecord = record; isOpenEditDialog = true"/>
        <section class="show-more" v-if="totalRecords > recordsCount">
          <a v-on:click="showMoreRecords">Show more...</a>
        </section>
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
  import { mapState, mapGetters, mapActions } from 'vuex'
  import { library } from '@fortawesome/fontawesome-svg-core'
  import { faUpload, faPlus, faFilter, faEdit } from '@fortawesome/free-solid-svg-icons'

  library.add(faUpload, faPlus, faFilter, faEdit)

  export default {
    components: { Record, ModalWindow, RecordForm, RecordFilter, RecordBatchForm, HtmlRecordsUploadForm },

    data: function() {
      return {
        isOpenHtmlRecordsUploadModal: false,
        isOpenRecordBatchFormModal: false,
        isOpenRecordFilterModal: false,
        isOpenNewRecordModal: false,
        isOpenEditDialog: false,
        currentRecord: {}
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

    methods: {
      ...mapActions(['fetchRecords', 'fetchCards']),

      recordsScroll(e) {
        e.preventDefault();
        const bound = e.target.getBoundingClientRect()
        console.log(bound.bottom, e.target.clientHeight);
        this.fetchRecords(this.recordsCount + 30)
      },

      showMoreRecords(e) {
        e.preventDefault;

        this.fetchRecords(this.recordsCount)
      }
    }
  }
</script>
<style lang="css" scoped>
  .navigation {
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

  .new-records {
    border: 3px dashed #e0e0e0;
    border-radius: 7px;
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-template-rows: 100%;
  }

  .new-records svg {
    cursor: pointer;
    align-self: center;
    justify-self: center;
  }

  .show-more {
    text-align: center;
    padding-bottom: 10px;
    grid-column-start: 2;
    grid-column-end: 3;
  }

  .show-more a {
    cursor: pointer;
  }

  @media (max-width: 1024px) {
    .records {
      height: calc(100vh - 15vh);
      grid-template-columns: 100%;
    }

    .new-records {
      grid-template-columns: 100%;
    }

    .new-records svg:last-child {
      display: none;
    }

    @supports (-webkit-overflow-scrolling: touch) {
      .records {
        height: calc(100vh - 30vh);
      }

      .show-more {
        grid-column-start: auto;
        grid-column-end: auto;
      }
    }
  }
</style>

<template>
    <div  id="right-main-column" class="d-flex flex-column flex-grow-1 overflow-auto">
      <div class="d-flex flex-column flex-fill">
        <div class="d-flex">
          <div class="btn-group mr-3">
            <button 
              type="button" 
              class="btn btn-small btn-outline-secondary" 
              @click="save"
              data-bs-toggle="tooltip" data-bs-placement="bottom" title="Save"
            >
              <i class="bi-save2"></i>
            </button>
            <button 
              type="button" 
              class="btn btn-small btn-outline-secondary" 
              @click="deleteOutput"
              data-bs-toggle="tooltip" data-bs-placement="bottom" title="Delete" 
            >
              <i class="bi-x-circle"></i>
            </button>
            <button 
              type="button" 
              class="btn btn-small btn-outline-secondary" 
              @click="selectText"
              data-bs-toggle="tooltip" data-bs-placement="bottom" title="Filter" 
            >
              <i class="bi bi-funnel"></i>
            </button>
            <button 
              type="button" 
              class="btn btn-small btn-outline-secondary" 
              @click="selectText"
              data-bs-toggle="tooltip" data-bs-placement="bottom" title="Search" 
            >
              <i class="bi bi-search"></i>
            </button>
          </div>
          <form class="row row-cols-lg-auto g-3 align-items-center">
            <div class="col-12">
              <div class="input-group">
                      <input v-model="search" type="text" class="form-control ms-1" placeholder="Search" aria-label="Searcg" aria-describedby="Search">
                      <div class="input-group-append">
                      </div>
              </div>
            </div>
          </form>
        </div>
        <textarea 
          v-show = "$store.state[name].text.length > 0"
          class="mt-1 d-flex flex-grow-1 h-100 form-control terminal text-white bg-dark"
          id="TextAreaOutput"
          rows="10"
          :value="output" 
          @change="outputChange"
        >
        </textarea>
      </div>
    </div>
</template>

<script>
import { saveAs } from 'file-saver';
export default {
  name: 'Output',
  props: {
    name: String
  },
  data: function (){
    return {
      search: ""
    }
  },
  computed:{
    output: function (){
      return this.$store.state[this.name]?.text ? this.$store.state[this.name]?.text : ""
    }
  },
  methods: {
    deleteOutput: function(){
      let payload = { name: this.name, text: ""}
      this.$store.commit("setOutputText",payload)
      console.log("DELETED",this.name)
    },
    outputChange: function(ev){
      let payload ={
        name: this.name,
        text: ev.target.value          
      }
      console.log(payload)
      this.$store.commit("setOutputText",payload)    
    },
    selectText: function () {
      let search_text = this.search
      let text = this.$store.state[this.name].text
      let index = text.search(search_text)
      if ( index >= 0 && search_text.length){
        const el = document.getElementById('TextAreaOutput');
        el.focus();
        el.setSelectionRange(index, index+search_text.length);        
      }
    },
    save: function(){
      var blob = new Blob([ this.$store.state[this.name].text ], {type: "text/plain;charset=utf-8"});
      saveAs( blob, this.name + ".txt" );
    }
  },
  mounted: function () {
    console.log("Mounted Output:", this.name)
  }  
}


</script>
<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
@import url("https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css");
.terminal {
    padding: 8px;
    font-family: courier new;
}
</style>
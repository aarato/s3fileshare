<script setup>
import AWSWindowClipboard from "./AWSWindowClipboard.vue";
import AWSWindowFiles from "./AWSWindowFiles.vue";
import AWSWindowLogin from "./AWSWindowLogin.vue";
import AWSButtonGroup from "./AWSButtonGroup.vue";
import {  reactive, onMounted, onBeforeMount } from 'vue'
import { store } from '../store.js'

let state = reactive(
  { 
    text: "", 
    id: null,
  }
)

function activateFiles(){       
    store.aws.navView="files";  
}
function activateClipboard(){    
    store.aws.navView="clipboard";   
}

onBeforeMount(()=>{
  state.id = crypto.randomUUID()
})

onMounted( async () => {
  console.log(`Mounted: AWSMain`)
})

</script>
 

<template>
  <div v-if="store.aws.credentials" class="d-flex flex-column flex-fill">
    <div class="mt-2 ms-1 me-1">
      <ul class="nav nav-tabs">
        <li  class="nav-item">
          <button id="navFiles"  class="nav-link" :class="store.aws.navView=='files' ? 'active' : ''" aria-current="page" @click="activateFiles" >
            Files
          </button>
        </li>
        <li class="nav-item">
          <button id="navClipboard" class="nav-link" :class="store.aws.navView=='clipboard' ? 'active' : ''" aria-current="page" @click="activateClipboard" >
            Clipboard
            <div v-if="store.awsWebSocketConnected" class="spinner-grow spinner-grow-sm" role="status">
              <span class="visually-hidden">Loading...</span>
            </div>
          </button>
        </li>
        <li class="nav-item ms-auto">
          <AWSButtonGroup/>
        </li>              
      </ul>   
    </div>
    <div class="d-flex flex-column flex-fill">
      <AWSWindowFiles v-if="store.aws.navView=='files'"/>
      <AWSWindowClipboard class="m-1" v-if="store.aws.navView=='clipboard'" id="awsupload"/>   
    </div>

  </div>
  <div v-else class="d-flex flex-column flex-fill justify-content-center align-items-center">
    <AWSWindowLogin/>
  </div>

</template>

<style scoped>

</style>
<script setup>
import AWSModalConfig from "./components/AWSModalConfig.vue";
import AWSModalShare from "./components/AWSModalShare.vue";
import AWSWindowMain from "./components/AWSWindowMain.vue";
import ToastMessage from './components/ToastMessage.vue';

import { onMounted } from 'vue'

onMounted(() => {
  console.log(`Mounted: App`)

})
</script>

<template>
  <div class="m-0 p-0 d-flex flex-column h-100 border-0 overflow-auto">
    <AWSWindowMain/>
  </div>       
  <AWSModalConfig/>
  <AWSModalShare/>
  <ToastMessage/>
</template>

<style>
html, body, #app {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: white;
}

</style>

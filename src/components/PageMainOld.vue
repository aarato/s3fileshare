<script setup>
import { onMounted } from 'vue'

import WindowAWSMain from "./WindowAWSMain.vue";
import WindowText from "./WindowText.vue";
import WindowChart from "./WindowChart.vue";

function submitfn(e){
  console.log(e)
}

onMounted( async () => {
  console.log(`Mounted: PageMain`)



})
</script>

<template>
  <div class="m-0 p-0 d-flex flex-column h-100 border-0 overflow-auto">
   
    <WindowAWSMain/>
    <WindowText  v-if="false"  />
    <WindowChart v-if="false" />
  </div>       
</template>

<style scoped>

</style>
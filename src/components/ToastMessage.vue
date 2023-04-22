<script setup>
import { onMounted, reactive, ref } from "vue";
import { store } from "../store.js"
import ButtonIcon from "./ButtonIcon.vue";

let state = reactive({ rooms: [] })


onMounted(() => {
    console.log(`Mounted: ToastMessage`)
});

</script>

<template>
  <div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 11">
    <div id="liveToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="toast-header">
        <strong class="me-auto">Information:</strong>
        <small>{{(new Date()).toLocaleTimeString('en-US')}}</small>
        <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
      <div class="toast-body">
        {{store.toastMessage}}
      </div>
    </div>
  </div>
</template>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
</style>
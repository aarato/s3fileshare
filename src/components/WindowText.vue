<script setup>
import {  reactive, onMounted, onBeforeMount } from 'vue'
import { store } from '../store.js'


let state = reactive({ text: "", id: null})

onBeforeMount(()=>{
  state.id = crypto.randomUUID()
})

onMounted(() => {
  console.log(`Mounted: WindowText`)
  const taElement = document.getElementById(state.id)

  setInterval(() => {  // Only update 100ms period
    if ( ! state.text !== store.textarea) {
      state.text = store.textarea
      taElement.scrollTop=taElement.scrollHeight; //scroll to bottom
    }
    
  }, 100);

})
</script>

<template>
      <div class="d-flex flex-column flex-grow-1 bg-secondary overflow-auto border border-secondary ">   
        <textarea 
          :id=state.id
          class="flex-grow-1 text-light p-1 bg-dark border-0" 
          cols="5" rows="5" contenteditable spellcheck="false" 
          readonly
        >{{state.text}}</textarea>
      </div>
</template>

<style scoped>

</style>
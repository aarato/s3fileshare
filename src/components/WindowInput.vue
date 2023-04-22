<template>
    <div :id="inputId" class="container mt-3 mb-3 p-0 bg-white text-dark">

      <!-- BODY WITH DYNAMIC INPUTS   -->
      <div class="d-flex align-items-center justify-content-center" >

        <!-- LABLE COLUMN -->
        <div class="d-flex flex-column justify-content-between">
          <div v-for="input in computed_inputs" :key="input.id" :style="input.style" class="m-1 d-flex justify-content-end">

            <!-- LABEL -->
            <div class="border border-3 border-white d-flex align-items-center justify-content-center">
              <label class="p-1 float-center text-nowrap" :for="input.id">{{input.label}}</label>
            </div>

            <!-- ICON -->
            <div class="d-flex align-items-center justify-content-center">
              <!-- <i class="bi bi-info-circle"></i> -->
              <WindowInputIcon icon="info-circle"  :text="input.information"/>
            </div>

          </div>
        </div>      

        <!-- INPUT COLUMN -->
        <div class="d-flex flex-column justify-content-between w-100">
          <div v-for="input in computed_inputs" :key="input.id" class=" m-1 ">
            
            <!-- INPUT TEXTAREA -->
            <textarea v-if="input.type=='textarea'" 
              class="form-control" 
              :style="input.style"
              :placeholder="input.placeholder"
              :readonly="input.readonly"
              v-model="inputs[input.id].value" 
            ></textarea>        

            <!-- INPUT SELECT -->
            <select v-else-if="input.type=='select'" 
              class="form-select"
              :value="inputs[input.id].value"
              @change="event => inputs[input.id].value = event.target.value"
              aria-label="select-input"
            ><option v-for="item in input.options" :key="item.text" :value="item.value" > {{item.text}} </option>
            </select>

            <!-- INPUT FILE -->
            <input v-else-if="input.type=='file'" 
              class="form-control" 
              :type="input.type"
              :name="input.name"
              @change="fileChange"
            > 


            <!-- @click="event => inputs[input.id].value = null"fff
              @change="event => inputs[input.id].value = event.target.files" -->

            <!-- INPUT TEXT -->
            <input v-else
              class="form-control" 
              :type="input.type"
              :placeholder="input.placeholder"
              :readonly="input.readonly"
              is-valid
              v-model="inputs[input.id].value" 
              @click="inputClick"
              @keyup.enter="$emit('submit', inputs)"
            >
          </div>
        </div>

      </div>

      <!-- FOOTER -->
      <div class="d-flex justify-content-end m-0">
        <slot name="footer" >
        <!-- FOOTER FALLBACK reference bt <template #footer></template>-->    
        </slot>
      </div>

    </div>
</template>
    
<script setup>
import {  ref, reactive, onMounted, onBeforeMount, computed, watch } from 'vue'
import { store } from '../store.js'
import WindowInputIcon from "./WindowInputIcon.vue";

const props = defineProps(
  {
    id: { type: String, required: false, default: 'input' }
  }
)

const inputId = ref(0);

const error_inputs  = reactive({
  username: { 
    label: "Username", 
    type: "text",
    placeholder: "Enter username here...there is an error",
    information: "If you see this there is an error!",
    value: ""
  },
  password: { 
    label: "Password", 
    type: "password",
    placeholder: "Enter password here...there is an error",
    information: "If you see this there is an error!",
    value: ""
  },
  textarea: { 
    label: "Textarea", 
    type: "textarea",
    placeholder: `If you see this there is an error: invalid store.inputs[${props.id}]  not found or invalid!`,
    information: `If you see this there is an error: invalid store.inputs[${props.id}] not found or invalid!`,
    value: ""
  },
})

const inputs = props.id && store.inputs && store.inputs[props.id] ? store.inputs[props.id] : error_inputs


// PRINT OUT FILE WHEN CHANGE
// watch(inputs.certfile, async (old_file, new_file) => {
//   if ( new_file.value){
//     var reader = new FileReader();
//     reader.onload = function() {
//       console.log(reader.result)
//     };
//     reader.readAsText(new_file.value);
//   }
// })


const computed_inputs = computed(() => {
  const inputs_object = inputs
  const inputs_array  = []
  for (const id in inputs_object) {
    if (Object.hasOwnProperty.call(inputs_object, id)) {
      inputs_array.push({
        id          : id,
        name        : id,
        label       : inputs_object[id].label ? inputs_object[id].label : id,
        type        : inputs_object[id].type  ? inputs_object[id].type :  "text",
        placeholder : inputs_object[id].placeholder ? inputs_object[id].placeholder : "",
        readonly    : inputs_object[id].readonly ? true : false,
        information : inputs_object[id].information ? inputs_object[id].information : id,
        options     : inputs_object[id].options ? inputs_object[id].options : [],
        style       : inputs_object[id].type == "textarea" ?  "resize: none;height: 100px" : null
      })
    }
  }
  return inputs_array;

})

function readFileToConsole(file){
  const reader = new FileReader();
  reader.onload = (evt) => {
    console.log(evt.target.result);
  };
  reader.readAsText(file)  
}



function fileChange(e){
  if ( e.target.files && e.target.files[0] ){
    inputs[e.target.name].value = e.target.files[0] 
    // readFileToConsole(inputs[e.target.name].value)
    // console.log(e.target.name,"has new value:", e.target.files[0] )
  }
  else{
    inputs[e.target.name].value = null
    // console.log(e.target.name,"set to null")
  }

}

function fileClick(e){
  console.log("fileClick",e.target)
}

onBeforeMount(()=>{
  inputId.value = props.id ? props.id : "input-" + crypto.randomUUID()
})

onMounted(() => {
    console.log(`Mounted: WindowInput`, inputId.value)
   
})
</script>

<style scoped>

</style>
    
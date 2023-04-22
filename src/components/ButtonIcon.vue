<script setup>
import { ref, onMounted, computed } from "vue";
import { Tooltip } from "bootstrap";

const props = defineProps({
  icon: {
    type: String,
    default: "question"
  },
  text: {
    type: String,
    default: "Undefined"
  },
  placement: {
    type: String,
    default: "bottom"
  },
  color: {
    type: String,
    default: "light"
  },
})

const iconClass = computed(() => {
  // return `bi bi-${props.icon}`
  return `bi text-${props.color} bi-${props.icon}`
})

const buttonIconInstance = ref(null);

function hideTooltip(){
  Tooltip.getInstance(buttonIconInstance.value).hide()
}

onMounted(() => {
  // console.log("Mounted:", props.icon)
  new Tooltip(buttonIconInstance.value);
});
</script>


<template> 
  <button 
    @click="hideTooltip"
    type="button" 
    class="btn btn-outline-secondary" 
    data-bs-toggle="tooltip" 
    :data-bs-placement="placement"
    :title="text" 
    ref="buttonIconInstance">
      <i :class="iconClass"></i>
  </button>  
</template>

<style scoped>
</style>
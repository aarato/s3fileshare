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
  }
})

const iconClass = computed(() => {
  return "bi bi-" + props.icon
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
  <i 
    :class="iconClass"
    data-bs-toggle="tooltip" 
    @click="hideTooltip"
    :data-bs-placement="placement"
    :title="text" 
    ref="buttonIconInstance"
  >
  </i>
</template>

<style scoped>
</style>
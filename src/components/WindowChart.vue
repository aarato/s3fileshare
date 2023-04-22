<script setup>
import {  reactive, onMounted, onBeforeMount } from 'vue'
import { store } from '../store.js'
import {TimeSeries,SmoothieChart} from 'smoothie'

let state = reactive({ text: "", id: null})

function resize() {
      let elementWidth = document.getElementById('chartContainer').offsetWidth;
      store.chart.width=  elementWidth
      // console.log(`Chart resized: ${elementWidth}X${elementHeight}`)
    }

onBeforeMount(()=>{
  state.idChart = crypto.randomUUID()
})

onMounted(() => {
  console.log(`Mounted: WindowText`)
  const series = new TimeSeries();
  store.chart.series = series
  var canvas = document.getElementById('chart');
  var chart = new SmoothieChart();
  chart.addTimeSeries(series, { strokeStyle: 'rgba(0, 255, 0, 1)' });
  chart.streamTo(canvas, 500);
  // setInterval(function() {
  //   series.append(Date.now(), Math.random() * 10000);
  // }, 500);  
  window.addEventListener("resize", () => {
    resize()
  })
  resize()
})
</script>

<template>
  <div id="chartContainer" >  
    <canvas id="chart" :width="store.chart.width" :height="store.chart.height"></canvas>
  </div>
        
</template>

<style scoped>

</style>
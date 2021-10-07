<template>
  <div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 11">
    <div id="liveToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="toast-header">
        <strong class="me-auto">Information:</strong>
        <small>{{(new Date()).toLocaleTimeString('en-US')}}</small>
        <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
      <div class="toast-body">
        {{$store.state.toastMessage}}
      </div>
    </div>
  </div>    
</template>

<script>
export default {
  name: 'ToastMessage',
  props: {
     name: {
          type: String,
          default: "ToastMessage"
        },  
  },
  data () {
    return {
      values: {}
    }
  },
  computed: {
    config: function (){
      return this.$store.state[this.name]
    },
  },
  methods:{

  },
  mounted: function () {
    console.log("Mounted:", this.name)
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

</style>
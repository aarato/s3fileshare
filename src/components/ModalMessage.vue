<template>
<!-- Modal -->
<div class="modal fade" id="exampleModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">{{title}}</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <pre>{{message}}</pre>
      </div>
      <div class="modal-footer">
        <slot name="footer" >
          <!-- FOOTER FALLBACK BUTTONS -->   
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          <button type="button" class="btn btn-primary">Save changes</button>
        </slot>        
      </div>
    </div>
  </div>
</div> 
</template>

<script>
export default {
  name: 'ModalMessage',
  props: {
    name: {
          type: String,
          default: "ModalMessage"
        },  
    title: {
          type: String,
          default: "Alert"
        },  
    message: {
          type: String,
          default: "This is a modal message"
        }  
  },
  data () {
    return {
      values: {},
      buffers: {},
      error_msg: "Form configuration is not available" 
    }
  },
  computed: {
    config: function (){
      return this.$store.state[this.name]
    },
  },
  methods:{
    inputClick: function ( ev ) {
      if ( ev?.target?.type == "file") {
        ev.target.value = ""
      }
    },
  },
  mounted: function () {
    console.log("Mounted:", this.name)
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

</style>
<template>
    <ul class="nav nav-tabs">
        <li class="nav-item">
        <button id="navDownload" class="nav-link active" aria-current="page" @click="navToggle('navDownload')" >Download</button>
        </li>
        <li class="nav-item">
        <button id="navUpload" class="nav-link       " aria-current="page" @click="navToggle('navUpload')" >Upload</button>
        </li>
        <li class="nav-item">
        <button id="navClipboard" class="nav-link       " aria-current="page" @click="navToggle('navClipboard')" >Clipboard</button>
        </li>
        <li v-show="false" class="nav-item">
        <button id="navSettings" class="nav-link       " aria-current="page" @click="navToggle('navSettings')" >Settings</button>
        </li>
    </ul>
</template>
<script>

export default {
  name: 'NavBar',
  components: {
    
  },
  data() {
    return {
      name: "NavBar"  
    }
  },
  computed: {
      store (){
          return this.$store
      }
  },  
  methods:{
    navToggle: async function (id){
        let visible = JSON.parse(JSON.stringify(this.$store.state.visible)) 
        document.getElementById("navDownload").classList.remove('active');
        document.getElementById("navUpload").classList.remove('active');
        document.getElementById("navClipboard").classList.remove('active');
        document.getElementById("navSettings").classList.remove('active');
        visible.navDownload = false
        visible.navUpload = false
        visible.navClipboard = false
        visible.navSettings = false

        if (id == 'navDownload') {
        document.getElementById("navDownload").classList.add('active');
        visible.navDownload = true
        }
        if (id == 'navUpload') {
        document.getElementById("navUpload").classList.add('active');
        visible.navUpload = true
        }
        if (id == 'navClipboard') {
        document.getElementById("navClipboard").classList.add('active');
        visible.navClipboard = true
        }
        if (id == 'navSettings') {
        document.getElementById("navSettings").classList.add('active');
        visible.navSettings = true
        }
        this.$store.commit("setState", { name:"visible", value: visible})
    },
  }, 
  mounted(){
    console.log("Mounted: NavBar ")
  }
}

</script>
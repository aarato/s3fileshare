<template>
  <div id="app" class="d-flex flex-column p-0">
    <Header/>
    <S3Files v-if="$store.state.credentials" name="S3Files" class="m-2"/>
    <ToastMessage/>
  </div>
</template>

<script>

import Header from './components/Header.vue'
import S3Files from './components/S3Files.vue';
import ToastMessage from './components/ToastMessage.vue';

export default {
  name: 'App',
  components: {
    Header,S3Files,ToastMessage
  },
  data () {
    return {
      url: process.env.NODE_ENV === "development" ? "http://localhost:8000": window.location.href,
      testinput: {
        name: "input",
        input_rows: [{"id": "user"}, {"id": "pass", "type":"password"}, {"id": "textbox1", "type": "textarea"}, {"id": "myselect", "type": "select", "options": [{"text": "One","value": "1"}, {"text": "Two","value": "2"}]}, {"id": "file1", "type": "file"}  ],
        values: { "user": "admin", "pass": "password", "textbox1": "Here's my input text...", "myselect": "1" }
      },
     
    }
  },
  methods:{

  },
  async mounted(){
    try {
      let jsonfile = process.env.NODE_ENV === "development" 
        ? await fetch("https://s3.us-east-1.amazonaws.com/copyruntest/awsconfig.json").then( response => response.text())
        : await fetch("awsconfig.json").then( response => response.text())
      let config = JSON.parse(jsonfile)
      this.$store.commit("setState", { name: "region", value: config.region } ) 
      this.$store.commit("setState", { name: "bucket", value: config.bucket } ) 
      this.$store.commit("setState", { name: "userPoolId", value: config.userPoolId } ) 
      this.$store.commit("setState", { name: "clientId", value: config.clientId } ) 
      this.$store.commit("setState", { name: "identityPoolId", value: config.identityPoolId } )       
      this.$store.commit("setState", { name: "websocket_api", value: config.websocket_api } )       
      console.log("Mounted: App")
    } catch (error) {
      console.log("App failed to download valid 'awsconfig.json' file!")
      console.log(error)
    }    

  }
}
</script>

<style>
html,
body {
  height: 100%;
  width: 100%;
  margin: 0
}
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  height: 100%;
}
.form-signin {
  width: 100%;
  max-width: 330px;
  padding: 15px;
  margin: auto;
}

</style>

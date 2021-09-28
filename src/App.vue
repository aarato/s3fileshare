<template>
  <div id="app" class="d-flex flex-column p-0">
    <Header/>
    <InputForm v-if="$store.state.credentials && false" :name="$store.state.input.name" class="border border-2 rounded-3 mt-2 ms-2 me-2 p-2 d-flex overflow-auto">
      <template v-slot:footer>
        <button class="btn btn-primary" @click='submit()'>Submit</button>
      </template>      
    </InputForm>
    <Output v-if="$store.state.credentials && false" :name="$store.state.output.name" class="m-2"/>
    <S3Files v-if="$store.state.credentials" :name="$store.state.inputS3Upload.name" class="m-2"/>
  </div>

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
import Header from './components/Header.vue'
import InputForm from './components/InputForm.vue'
import Output from './components/Output.vue';
import S3Files from './components/S3Files.vue';
import { Toast } from "bootstrap" ;
import { S3Client, ListObjectsCommand  } from "@aws-sdk/client-s3";


export default {
  name: 'App',
  components: {
    InputForm,Output,Header,S3Files
  },
  data () {
    return {
      url: process.env.NODE_ENV === "development" ? "http://localhost:8000": window.location.href,
      toastMessage: "",
      testinput: {
        name: "input",
        input_rows: [{"id": "user"}, {"id": "pass", "type":"password"}, {"id": "textbox1", "type": "textarea"}, {"id": "myselect", "type": "select", "options": [{"text": "One","value": "1"}, {"text": "Two","value": "2"}]}, {"id": "file1", "type": "file"}  ],
        values: { "user": "admin", "pass": "password", "textbox1": "Here's my input text...", "myselect": "1" }
      },
     
    }
  },
  methods:{

    submit: function () {
      var bsAlert = new Toast( document.getElementById('liveToast') );//inizialize it      
      this.$store.state.toastMessage = "Submit pushed"
      bsAlert.show();//show it 
      const s3Client = new S3Client({
          region: this.$store.state.region,
          credentials: this.$store.state.credentials
        });
      let command = new ListObjectsCommand({ Bucket: "548266769309"});
      s3Client.send(command)
      .then((result) =>{
        this.$store.commit("setOutput", {name: "output", text: JSON.stringify(result, null, 2)} )
        console.log("Success",result)
      })
      .catch((result) =>{
        this.$store.commit("setOutput", {name: "output", text: JSON.stringify(result.message, null, 2)} )
        console.log("Error",result)
      })
      
    }
  },
  async mounted(){
    try {
      let jsonfile = process.env.NODE_ENV === "development" 
        ? await fetch("https://s3.us-east-1.amazonaws.com/copyrun/awsconfig.json").then( response => response.text())
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

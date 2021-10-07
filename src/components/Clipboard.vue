<template>
    <div class="d-flex flex-column flex-fill">
      <textarea class="form-control d-flex flex-fill" name="clipboardTextarea" id="clipboardTextarea" cols="30" rows="10" v-model="$store.state.clipboard"></textarea>
    </div>
</template>
<script>
// var W3CWebSocket = require('websocket').w3cwebsocket;
import { w3cwebsocket as W3CWebSocket } from "websocket"
import { Signer } from "@aws-amplify/core"
import { setStatusMessage } from "./helpers.js"

export default {
  name: 'Clipboard',
  components: {
    
  },
  data() {
    return {
      name: "Clipboard",
      awsWebSocket: null,
      localWebSocketId: null
    }
  },
  computed: {
      store (){
          return this.$store
      }
      
  },  
  methods:{
    test: async function (){
      console.log("Clipboard Test1")
    },
    makeid: function (length) {
      var result           = '';
      var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      var charactersLength = characters.length;
      for ( var i = 0; i < length; i++ ) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
      }
      return result;
    },
      
  }, 
  async mounted(){
    console.log("Mounted: Clipboard")

    // SIGN WEBSOCKET URL FOR SECURITY
    let store = this.$store
    let url = ""
    try {
      let creds = await store.state.credentials()
      let urlToSign = store.state.websocket_api
      let accessInfo = {
        access_key: creds.accessKeyId,
        secret_key: creds.secretAccessKey,
        session_token: creds.sessionToken
      }
      url = Signer.signUrl(urlToSign,accessInfo)
      // console.log(url)      
    } catch (error) {
      console.log(error)
    }

    // SIGN WEBSOCKET URL FOR SECURITY
    this.awsWebSocket = new W3CWebSocket(url)
    let awsWebSocket =  this.awsWebSocket 
    this.localWebSocketId =  this.makeid(5)
    let localWebSocketId = this.localWebSocketId
    let lastClipboard = store.state.clipboard
    let lockClipboard = false // To prevent message sending while receiving message
    var wsSenderInterval = null
    awsWebSocket.onopen = function () { // event is an option here
      console.log("WebSocket is open now:", localWebSocketId);
      setStatusMessage("WebSocket open")
      wsSenderInterval = setInterval(()=>{
        if ( lastClipboard != store.state.clipboard && !lockClipboard) {
          // console.log("Clipboard Change")
          lastClipboard = store.state.clipboard
          let jsonData = { localWsId: localWebSocketId, message: lastClipboard }
          let message = JSON.stringify({"action":"sendmessage", "data": JSON.stringify(jsonData)})
          awsWebSocket.send(message);
        }
      }, 1000)
    };
    awsWebSocket.onclose = function() {
      setStatusMessage("WebSocket closed")
      console.log("WebSocket is closed now:",localWebSocketId);
      clearInterval(wsSenderInterval)
    };
    awsWebSocket.onerror = function(event) {
      setStatusMessage("WebSocket error")
      console.log("WebSocket error:",event);
      clearInterval(wsSenderInterval)
    };
    awsWebSocket.onmessage = function (event) {
      // console.log("EVENT",event);
      let jsonData = JSON.parse(event.data)
      if (jsonData.localWsId != localWebSocketId){
        lockClipboard = true
        lastClipboard = jsonData.message
        store.state.clipboard = jsonData.message    
        lockClipboard = false
      }
    }     
  },
  async unmounted(){
    this.awsWebSocket.close();
  }
}

</script>
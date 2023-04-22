<script setup>
import {  reactive, onMounted, onBeforeMount, onUnmounted } from 'vue'
import { store } from '../store.js'
import { Signer } from "@aws-amplify/core"
import { Toast } from "bootstrap" ;

const state = reactive({ 
  text: "",
  id: null,
  awsWebSocket: null
})
const localWebSocketId =  makeid(5)  // random id for my websocket connection

// Creates random ID for websocket
function makeid (length) {
  var result           = '';
  var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  var charactersLength = characters.length;
  for ( var i = 0; i < length; i++ ) result += characters.charAt(Math.floor(Math.random() * charactersLength));
  return result;
}

function message(msg){
  store.toastMessage = msg
  var bsAlert = new Toast( document.getElementById('liveToast') );//inizialize it      
  bsAlert.show();//show it   
}

async function wsconnect () {
  let creds = await store.aws.credentials()
  let urlToSign = store.inputs.awsConfig.websocket_api.value
  let accessInfo = {
        access_key: creds.accessKeyId,
        secret_key: creds.secretAccessKey,
        session_token: creds.sessionToken
      }
  let url = Signer.signUrl(urlToSign,accessInfo)

  
  let lastClipboard = store.aws.clipboard // store last clipboard content before change
  let lockClipboard = false // To prevent message sending while receiving message
  let wsSenderInterval = null // my loop interval for checking changes and push it via Websocket if there's a change
  state.awsWebSocket = new WebSocket(url)
  const awsWebSocket = state.awsWebSocket
  
  awsWebSocket.addEventListener("open", (event) => { // event is an option here
    message("WebSocket connected")
    console.log("WebSocket is open for:",localWebSocketId);
    store.awsWebSocketConnected = true
    wsSenderInterval = setInterval(()=>{
      if ( lastClipboard != store.aws.clipboard && !lockClipboard) {
        lastClipboard = store.aws.clipboard
        let jsonData = { localWsId: localWebSocketId, message: lastClipboard }
        let message = JSON.stringify({"action":"sendmessage", "data": JSON.stringify(jsonData)})
        // console.log("Clipboard Change", message)
        awsWebSocket.send(message);
      }
    }, 1000)
  });

  awsWebSocket.addEventListener("close", () => {
    message("WebSocket closed")
    console.log("WebSocket is closed for:",localWebSocketId);
    clearInterval(wsSenderInterval)
    state.awsWebSocket = null;
    store.awsWebSocketConnected = false
  });

  awsWebSocket.addEventListener("error", (event) => {
    message("WebSocket error")
    console.log("WebSocket error:",event);
    clearInterval(wsSenderInterval)
  });

  awsWebSocket.addEventListener("message", (event) => {
    // console.log("EVENT",event);
    let jsonData = JSON.parse(event.data)
    if (jsonData.localWsId != localWebSocketId){
      lockClipboard = true
      lastClipboard = jsonData.message
      store.aws.clipboard = jsonData.message    
      lockClipboard = false
    }
  })     

}

async function wsdisconnect () {
  if (state.awsWebSocket){
    state.awsWebSocket.close()
  }
}

onBeforeMount(()=>{
  state.id = crypto.randomUUID()
})

onMounted( async () => {
  console.log(`Mounted: AWSClipboard`)
  await new Promise(resolve => {
    const interval = setInterval(() => {
      if (store.aws.credentials) {
        resolve(true);
        clearInterval(interval);
      };
    }, 1000);
  });
  wsconnect()
})

onUnmounted( async () => {
  wsdisconnect()
  console.log(`UnMounted: AWSClipboard`)
})


</script>

<template>
  <div class="d-flex flex-column flex-fill">
    <textarea 
      class="form-control d-flex flex-fill" 
      name="clipboardTextarea" 
      id="clipboardTextarea" 
      cols="30" rows="10" 
      placeholder="Share real-time here with other authenticated browsers..."
      v-model="store.aws.clipboard">
    </textarea>
  </div>
</template>

<style scoped>
</style>
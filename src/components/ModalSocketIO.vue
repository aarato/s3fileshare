<script setup>
import { onMounted, reactive, ref, computed} from "vue";
import { store } from "../store.js"
// import ButtonIcon from "./ButtonIcon.vue";
import { io } from "socket.io-client";
import WindowInput from "./WindowInput.vue";

let connected = ref(false)
let active = ref(false)

function connect(){
    store.socket = io( store.inputs.socketio.url.value)
    const socket = store.socket
    const url = store.inputs.socketio.url.value
    let lastSocketId = null
    socket.on('connect', () => {
        lastSocketId = socket.id
        connected.value = true
        active.value = true
        console.log(`Socket.io: connected ${socket.id} to ${url}`)
    });

    socket.on('disconnect', () => {
        connected.value = false
        active.value = false
        console.log(`Socket.io: disconnected ${lastSocketId} from ${url}`)
    });
    socket.on("connect_error", (err) => {
        console.log(`Socket.io: connect error: ${err.message}`);
        connected.value = false
        active.value = true
    });

    socket.on('data', (data) => {
        if (typeof data != "string"){
        data = JSON.stringify(data)
        }
        store.textarea += data + "\n"
        if ( store.chart.series && !isNaN(data)){
        store.chart.series.append(Date.now(), +data);
        }    
        // console.log(`Data ${data}`)
    });  
}

function disconnect(){
    if( store.socket && store.socket.disconnect){
        store.socket.disconnect()
    }
    connected.value = false
    active.value = false
    store.socket = null
}


function save(){
    disconnect()
    connect()
}


onMounted(() => {
    console.log(`Mounted: ModalSocketIO`)
    if (store.inputs.socketio && store.inputs.socketio.connect && store.inputs.socketio.connect.value) {
        // console.log("Socket.io is connecting to:", store.inputs.socketio.url.value)
        connect ()
    }else{
        // console.log("Socket.io auto connection disabled")
    }
});



</script>

<template>
    <!-- Modal -->
    <div class="modal fade" id="modalSocketIO" tabindex="-1" aria-labelledby="modalSocketIOLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="modalSocketIOLabel">Socket.IO settings</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <WindowInput id="socketio"/>
          </div>
          <div class="modal-footer">
            <button v-if="!connected && !active " type="button" class="btn btn-secondary" @click="connect">Connect</button>
            <button v-if="connected || active" type="button" class="btn btn-secondary" @click="disconnect" >Disconnect</button>
            <button type="button" class="btn btn-secondary" @click="save">Save</button>
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>
</template>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
</style>
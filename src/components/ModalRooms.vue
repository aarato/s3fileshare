<script setup>
import { onMounted, reactive, ref } from "vue";
import { store } from "../store.js"
import ButtonIcon from "./ButtonIcon.vue";

let state = reactive({ rooms: [] })
const socket = store.socket

function updateRooms(){
    socket.emit("get_rooms", null, (rooms)=>{
            state.rooms = rooms
            // console.log(rooms)
        })       
}

function selectRoom(e){
    const room_name = e.target.name
    // console.log(room_name)

    state.rooms.forEach(room => {
        if (room.name == room_name) {
            if (room.member){
                socket.emit("leave_room", room_name, (success)=>{
                    console.log("Leave room", success ? "OK" : FAIL)
                })
            }
            else{
                socket.emit("join_room", room_name, (success)=>{
                    console.log("Join room", success ? "OK" : FAIL)
                })
            }
        }
    });
    updateRooms()
}

onMounted(() => {
    console.log(`Mounted: ModalRooms`)
    const myModal = document.getElementById('modalRooms')
    myModal.addEventListener('shown.bs.modal', () => {
        console.log("Modal shown")
        updateRooms()
    })    
});



</script>

<template>
    <!-- Modal -->
    <div class="modal fade" id="modalRooms" tabindex="-1" aria-labelledby="modalRoomsLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="modalRoomsLabel">Available Sources</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div v-if="state.rooms.length" class="list-group">
                <button 
                    type="button" 
                    class="list-group-item list-group-item-secondary list-group-item-action"
                    :class="room.member? 'active ' : ''"
                    :name="room.name"
                    v-for="room in state.rooms"
                    @click="selectRoom"
                >
                    <i v-if="!room.member" class="bi bi-square"></i>
                    <i v-if=" room.member" class="bi bi-check-square"></i>
                    &nbsp;{{room.name}}</button>
            </div>
            <p v-else class="m-0">No available source is connected!</p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>
</template>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
</style>
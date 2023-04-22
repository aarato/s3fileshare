<script setup >
import AWSButtonGroup from "./AWSButtonGroup.vue";
import { onMounted } from "vue";
import { store } from "../store.js"
import ButtonIcon from "./ButtonIcon.vue";
import { Modal } from 'bootstrap'

function login(){
  store.loggedIn = true
}

function logout(){
  store.loggedIn = false
}

function trash(){
  store.textarea = ""
}

function rooms(){
  let elem = document.getElementById("modalRooms")
  let modal = new Modal(elem)
  modal.show()    
}

function socketio(){
  let elem = document.getElementById("modalSocketIO")
  let modal = new Modal(elem)
  modal.show()    
}

function aws_settings(){
  let elem = document.getElementById("modalAWSSettings")
  let modal = new Modal(elem)
  modal.show()    
}


onMounted(() => {

});
</script>

<template>
  <nav id="Navbar" class="ps-1 pe-1 navbar sticky-top navbar-expand navbar-dark bg-dark justify-content-between">
  <!-- <div class="form-floating ms-0">
      <input readonly type="text" class="form-control bg-dark text-white" id="floatingStatus" placeholder="Status" value="Not logged in">
      <label class="text-white" for="floatingStatus">Current Status</label>
  </div>        -->


      <!-- <div class="btn-group">
        <ButtonIcon icon="list-task"  text="Sources" @click="rooms"/>
        <ButtonIcon icon="trash"      text="Clear" @click="trash"/>
        <ButtonIcon v-if="false" icon="house-door" text="Home"/>
        <ButtonIcon v-if="false" icon="clipboard"  text="Copy"/>
      </div>     -->

    <div class="btn-group">


<!-- 
        <ButtonIcon v-if="!store.loggedIn" @click="login " icon="box-arrow-in-right" text="Login"/>
        <ButtonIcon v-if=" store.loggedIn" @click="logout" icon="box-arrow-right"    text="Logout"/>
 -->
      
 <!-- <ButtonIcon icon="lightning" text="Socket.io Settings" @click="socketio"/> -->
 <!-- <ButtonIcon icon="gear" text="Settings"/> -->
    </div>   
    <AWSButtonGroup v-if="store.aws.credentials"/>      
  </nav>
</template>

<style scoped>

</style>
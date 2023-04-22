import { reactive } from 'vue'
import { io } from "socket.io-client";

export const store = reactive({
  textarea: "",
  loggedIn: false,
  socket: io("http://localhost:5000"),
  series: null,
  chart:{
    series: null,
    width: 500,
    height: 100
  }

})



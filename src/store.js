import { createStore } from 'vuex'

const store = createStore({
    state () {
      return {
        url: "http://localhost;8000",
        username: "admin",
        password: "",
        status: "not logged in",
        socket: null,
        region: "",  //"us-east-2"
        bucket: "",  //"accountid_name"
        userPoolId: "", //us-east-2_j3Vcx1Ss3
        clientId: "", //7d725jjrn1ve7gpce38bo06rvp
        identityPoolId: "",  //us-east-2:79ae3f9e-4e21-4a17-a624-d7818293439e
        websocket_api: "", 
        idToken: "",
        credentials: null,
        toastId: "liveToast",
        toastMessage: "",
        clipboard: "",
        uploadPartSize: "5242880",
        uploadPercent: "0",
        input: {
          name: "input",
          input_rows: [
            {
              "id": "myselect", 
              "type": "select",
              "label": "AWS Action",
              "options": [
                {"text": "List S3 Objects","value": "ListObjectsCommand"}, 
                {"text": "Upload File","value": "UploadFile"}]},
          ],
          values: {
            "myselect": "ListObjectsCommand"
          }
        },
        output: {
          name: "output",
          text: "My test output text..."
        },
        inputLogin:{
          input_rows: [
            { id: "username", label: "Username" },
            { id: "password", label: "Password", type: "password"}
          ],
          values:{
            username: "admin",
            password: process.env.NODE_ENV === "development" ? "Admin123#": ""
          },
        },
        inputS3Upload:{
          name: "inputS3Upload",
          input_rows: [ {"id": "s3fileupload", "type": "file", label: "S3 Upload", information: "Pick a file that you want to upload to a predefined S3 bucket"}  ],
          values:{
            s3fileupload: null,
          }
        },
        visible: {
          navDownload: true,
          navUpload: false,
          navClipboard: false,
          navSettings: false
        }   
      }
    },
    mutations: {
      setStatus (state,payload) {
        state.status = payload
      },
      setState (state,payload) {
        if ( payload?.name in state ) {
          state[payload.name] = payload.value ? payload.value : null
        }
        else{
          return console.log (`No name: ${payload.name} found!`)
        }
      },
      setInput (state,input) {
        if (input.name) {
          state.input.name = input.name
          state.input.input_rows = input.input_rows ? input.input_rows : []
          state.input.values = {}
          for (const row of input.input_rows ) {
            state.input.values[row.id] = row.value ? row.value : ""
          }
        }
        else{
          state.input = {
            name: null,
            input_rows: [],
            values: {}
          }
        }      
      },
      setOutput (state,output) {
        if (output.name){
          state.output.name = output.name ? output.name : "output"
          state.output.text = output.text ? output.text : ""          
        }
        else{
          state.output = {
            name: null,
            text: ""
          }
        }

      },
      setInputValue (state,payload) {
        if ( ! state[payload.name] ) { 
          return console.log (`No input name ${payload.name} found!`)
        }
        if ( ! state[payload.name].values ) {
          state[payload.name].values = {}
        }
        state[payload.name].values[payload.id] = payload.value
      },
      setInputRows (state,payload) {
        if ( ! state[payload.name] ) { 
          return console.log (`No input name ${payload.name} found!`)
        }
        let input = state[payload.name]
        input.input_rows = payload.input_rows
        if ( !input.values ) {
          input.values = {}
        }
        for (const row of input.input_rows) {
          if ( ! input.values[row.id] ) {
            input.values[row.id] = row.value
          }
        }
      },
      setOutputText (state,payload) {
        if ( ! state[payload.name] ) { 
          return console.log (`No output name ${payload.name} found!`)
        }
        state[payload.name].text = payload.text
      }

    }
  })

export default store

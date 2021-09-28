<template>
  <div  id="right-main-column" class="d-flex flex-column flex-grow-1 overflow-auto">
    <div class="d-flex flex-column">
      <InputForm v-if="$store.state.credentials && true" :name="$store.state.inputS3Upload.name" class="border border-2 rounded-3 p-2 d-flex overflow-auto">
        <template v-slot:footer>
          <button class="btn btn-primary me-1" data-bs-toggle="modal" data-bs-target="#clipboardModal">Clipboard</button>        
          <button class="btn btn-primary me-1" @click='listObjects()'>Refresh</button>
          <button class="btn btn-primary" @click='upload()'>Upload</button>
        </template>      
      </InputForm>
    </div>
    <div class="d-flex flex-column flex-fill">
        <table class="table">
          <thead>
            <tr>
              <th scope="col">Key</th>
              <th scope="col">Size</th>
              <th scope="col">Last Modified</th>
              <th scope="col">Expire on</th>
              <th scope="col">Action</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="bucket in buckets" :key="bucket.Key" >
              <!-- <td><a href="#" @click="test()">{{bucket.Key}}</a></td> -->
              <td><a href="#" @click="download(bucket.Key)">{{bucket.Key}}</a></td>
              <td>{{bucket.Size}}</td>
              <td>{{bucket.LastModified}}</td>
              <td>{{bucket.expireDate}}</td>
              <td>
                <div class="btn-group">
                  <button type="button" class="btn btn-small btn-outline-secondary" @click="deleteKey(bucket.Key)" data-bs-toggle="tooltip" data-bs-placement="bottom" title="Delete">
                    <i class="bi-trash-fill" ></i>
                  </button>
                  <button type="button" class="btn btn-small btn-outline-secondary" @click="GetSignedUrl(bucket.Key)" data-bs-toggle="tooltip" data-bs-placement="bottom" title="Pre-signed URL to clipboard">
                    <i class="bi-pen-fill" ></i>
                  </button>
                </div>
              </td>              
            </tr>
          </tbody>
        </table>
    </div>  

    <!-- Modal -->
    <div class="modal fade" id="clipboardModal" tabindex="-1" aria-labelledby="clipboardModalLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title text-dark" id="clipboardModalLabel">Clipboard</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body text-dark">
            <textarea class="form-control" name="clipboardTextarea" id="clipboardTextarea" cols="30" rows="10" v-model="$store.state.clipboard"></textarea>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>  

  </div>

</template>

<script>
import InputForm from './InputForm.vue'
import { S3Client, ListObjectsCommand, GetObjectCommand, PutObjectCommand, DeleteObjectCommand   } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { Signer } from "@aws-amplify/core"
import { add } from 'date-fns'
import { Toast } from "bootstrap" ;
import { saveAs } from 'file-saver';
// var W3CWebSocket = require('websocket').w3cwebsocket;
import { w3cwebsocket as W3CWebSocket } from "websocket"
export default {
  name: 'S3Files',
  components: {
    InputForm
  },
  props: {
    name: String
  },
  data: function (){
    return {
      search: "",
      // buckets: [{Key: 1},{Key: 2},{Key: 3}]
      buckets: []
    }
  },
  computed:{
    output: function (){
      return this.$store.state[this.name]?.text ? this.$store.state[this.name]?.text : ""
    }
  },
  methods: {
    test: function(){
      console.log("test")
    },
    GetSignedUrl: async function (key){
      const s3Client = new S3Client({
        region: this.$store.state.region,
        credentials: this.$store.state.credentials
      });
      const command = new GetObjectCommand({ Bucket:  this.$store.state.bucket, Key: key});
      const url = await getSignedUrl(s3Client, command, { expiresIn: 3600 });
      navigator.clipboard.writeText(url)
      console.log(url)
      var bsAlert = new Toast( document.getElementById('liveToast') );//inizialize it      
      this.$store.state.toastMessage = `Pre-signed URL for ${key} copied to clipboard.`
      bsAlert.show();//show it    

    },
    deleteKey: async function (key) {
      let bsAlert = new Toast( document.getElementById('liveToast') ); 
      const s3Client = new S3Client({
        region: this.$store.state.region,
        credentials: this.$store.state.credentials
      });
      let params = { Bucket:  this.$store.state.bucket, Key: key}
      try {
        await s3Client.send(new DeleteObjectCommand(params));
        await this.listObjects()
        this.$store.state.toastMessage = `Sucessfully deleted ${key}.`
        bsAlert.show();
      }catch (err) {
        this.$store.state.toastMessage = `Sucessfully deleted ${key}.`
        bsAlert.show();
        return alert(`There was an error deleting ${key}: `, err.message);
      }

    },
    getClipboard: async function(){
      let key="files/clipboard.txt"
      try {
        const s3Client = new S3Client({
          region: this.$store.state.region,
          credentials: this.$store.state.credentials
        });
        let command = new GetObjectCommand ({ Bucket:  this.$store.state.bucket, Key: key});
        let response = await s3Client.send(command);
        let reader = await response.Body.getReader()
        let blob = await reader.read()
        console.log(new TextDecoder().decode(blob.value))
        this.$store.state.clipboard = new TextDecoder().decode(blob.value);
      } 
      catch (error) {
        this.$store.state.clipboard = ""
        console.log("Clipboard get failed",error)
        this.saveClipboard()
      }
    },
    saveClipboard: async function () {
      const filename = "files/clipboard.txt"
      const uploadParams = {
        Bucket:  this.$store.state.bucket,
        Key: filename,
        Body: this.$store.state.clipboard
      };

      try {
        const s3Client = new S3Client({
          region: this.$store.state.region,
          credentials: this.$store.state.credentials
        });
        await s3Client.send(new PutObjectCommand(uploadParams));
        await this.listObjects()         
      } catch (err) {
        return alert("There was an error saving the clipboard", err.message);
      }
    },    
    upload: async function () {
      let bsAlert = new Toast( document.getElementById('liveToast') );    
      let files = this.$store.state.inputS3Upload.values.s3fileupload
      if (files?.length){
        const file = files[0];
        const filename = "files/" + file.name
        const uploadParams = {
          Bucket:  this.$store.state.bucket,
          Key: filename,
          Body: file
        };

        try {
          const s3Client = new S3Client({
            region: this.$store.state.region,
            credentials: this.$store.state.credentials
          });
          await s3Client.send(new PutObjectCommand(uploadParams));
          this.$store.state.toastMessage = `Sucessfully uploaded ${filename} file.`
          bsAlert.show();
          await this.listObjects()         
        } catch (err) {
          return alert("There was an error uploading your file: ", err.message);
        }

      }
      else{
        this.$store.state.toastMessage = `No file selected for upload!`
        bsAlert.show();
      }

    },    
    download: async function(key){
      let bsAlert = new Toast( document.getElementById('liveToast') );    
      try {
        let filename = key.split("/").pop()
        console.log("Download",filename)
        const s3Client = new S3Client({
          region: this.$store.state.region,
          credentials: this.$store.state.credentials
        });
        let command = new GetObjectCommand ({ Bucket:  this.$store.state.bucket, Key: key});
        let response = await s3Client.send(command);
        let result = new Response(response.Body, {});
        let blob = await result.blob()
        saveAs( blob, filename);
      } 
      catch (error) {
        this.$store.state.toastMessage = `Download failed!`
        bsAlert.show();
        console.log("Error",error)
      }
    },
    listObjects: async function(){
      let bsAlert = new Toast( document.getElementById('liveToast') );  
      const s3Client = new S3Client({
          region: this.$store.state.region,
          credentials: this.$store.state.credentials
        });
      let command = new ListObjectsCommand({ Bucket:  this.$store.state.bucket, Prefix: "files"});
      return s3Client.send(command)
      .then((result) =>{
        if ( ! result.Contents ) {
          this.buckets = []
          return ;
        }
        this.buckets = result.Contents       
        for (let index = 0; index < this.buckets.length; index++) {
          let expireDate = add(this.buckets[index].LastModified, {days: 2})
          expireDate.setUTCHours(0, 0, 0, 0)
          this.buckets[index].expireDate = expireDate
        }
        // console.log("Success",this.buckets)
      })
      .catch((result) =>{
        this.$store.state.toastMessage = `S3 folder refresh failed!`
        bsAlert.show();
        this.$store.commit("setOutput", {name: "output", text: JSON.stringify(result.message, null, 2)} )
        console.log("Error",result)
      })
    },
  makeid: function (length) {
      var result           = '';
      var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      var charactersLength = characters.length;
      for ( var i = 0; i < length; i++ ) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
      }
      return result;
    }
  },
  mounted: async function () {
    console.log("Mounted:", this.name)
    this.listObjects()
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

    // let exampleSocket = new WebSocket(url);
    let exampleSocket =  new W3CWebSocket(url)
    const localWsId =  this.makeid(5)
    let lastClipboard = store.state.clipboard
    let lockClipboard = false // To prevent message sending while receiving message
    var wsSenderInterval = null
    exampleSocket.onopen = function () { // event is an option here
      // console.log(event)
      wsSenderInterval = setInterval(()=>{
        if ( lastClipboard != store.state.clipboard && !lockClipboard) {
          // console.log("Clipboard Change")
          lastClipboard = store.state.clipboard
          let jsonData = { localWsId: localWsId, message: lastClipboard }
          let message = JSON.stringify({"action":"sendmessage", "data": JSON.stringify(jsonData)})
          exampleSocket.send(message);
        }
      }, 1000)
    };
    exampleSocket.onclose = function(event) {
      console.log("WebSocket is closed now.",event);
      clearInterval(wsSenderInterval)
    };
    exampleSocket.onerror = function(event) {
      console.log("WebSocket error:",event);
      clearInterval(wsSenderInterval)
    };
    exampleSocket.onmessage = function (event) {
      // console.log("EVENT",event);
      let jsonData = JSON.parse(event.data)
      if (jsonData.localWsId != localWsId){
        lockClipboard = true
        lastClipboard = jsonData.message
        store.state.clipboard = jsonData.message    
        lockClipboard = false
      }
    }    

  }  
}


</script>
<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
@import url("https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css");
.terminal {
    padding: 8px;
    font-family: courier new;
}
</style>
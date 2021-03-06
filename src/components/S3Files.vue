<template>
  <div  id="right-main-column" class="d-flex flex-column flex-grow-1 overflow-auto">
    <NavBar/>
    <Upload v-if="$store.state.visible.navUpload"/>
    <Download v-if="$store.state.visible.navDownload"/> 
    <Clipboard v-if="$store.state.visible.navClipboard"/>
    <ModalMessage :title="modalTitle" :message="modalMessage">
      <template v-slot:footer>
        <button type="button" class="btn btn-danger" @click="deleteMultipartUploads">Delete</button>
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
      </template>
    </ModalMessage>      
  </div>
</template>

<script>
import ModalMessage from './ModalMessage.vue'
import NavBar from './NavBar.vue'
import Clipboard from './Clipboard.vue'
import Download from './Download.vue'
import Upload from './Upload.vue'
import { S3Client, AbortMultipartUploadCommand, UploadPartCommand, ListMultipartUploadsCommand, ListPartsCommand , GetObjectCommand, PutObjectCommand, DeleteObjectCommand   } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { Upload as UploadMulti } from "@aws-sdk/lib-storage";
import { Toast } from "bootstrap" ;
import { saveAs } from 'file-saver';
import { Modal } from 'bootstrap';

export default {
  name: 'S3Files',
  components: {
    ModalMessage,NavBar,Clipboard,Download,Upload
  },
  props: {
    name: {
          type: String,
          default: "S3Files"
        }  
  },
  data: function (){
    return {
      search: "",
      // buckets: [{Key: 1},{Key: 2},{Key: 3}]
      myModal: null,
      buckets: [],
      uploadOngoing: false,
      modalTitle: "Init Title...",
      modalMessage: "Init Message...",
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
    checkExistingMultipartUploads: async function (){
      let uploadsInProgress = await this.listMultipart()
      const existingUploads = []
      if (uploadsInProgress?.length > 0){
        for (let index = 0; index < uploadsInProgress.length; index++) {
          const file = uploadsInProgress[index];
          const multipartUpload = await this.listMultipartKey(file.Key, file.UploadId)
          existingUploads.push(file.Key )
          console.log("Existing multi-part upload in progress found:",multipartUpload.Key)
        }
      }
      return existingUploads
    },
    deleteMultipartUploads: async function (){
      let uploadsInProgress = await this.listMultipart()
      if (uploadsInProgress?.length > 0){
        const s3Client = new S3Client({
          region: this.$store.state.region,
          credentials: this.$store.state.credentials
        });        
        for (let index = 0; index < uploadsInProgress.length; index++) {
          const file = uploadsInProgress[index]
          console.log("Delete Progress:",file.Key)
          let params = { Bucket:  this.$store.state.bucket, Key: file.Key  ,UploadId: file.UploadId}
          try {
            await s3Client.send( new AbortMultipartUploadCommand( params) );
          } catch (error) {
            console.log("Multipart delete failed!\n", error)
          }
        }
      }
      this.myModal.hide();   
    },
    GetSignedUrl: async function (key){
      const s3Client = new S3Client({
        region: this.$store.state.region,
        credentials: this.$store.state.credentials
      });
      const command = new GetObjectCommand({ Bucket:  this.$store.state.bucket, Key: key});
      const url = await getSignedUrl(s3Client, command, { expiresIn: 3600 });
      navigator.clipboard.writeText(url)
      this.$store.state.clipboard = url
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
        this.uploadOngoing = true
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
        this.uploadOngoing = false

      }
      else{
        this.$store.state.toastMessage = `No file selected for upload!`
        bsAlert.show();
      }

    },    
    uploadMulti : async function () {
      let store = this.$store
      let bsAlert = new Toast( document.getElementById('liveToast') );    
      let files = this.$store.state.inputS3Upload.values.s3fileupload
      if (files?.length){
        this.uploadOngoing = true
        const file = files[0];
        const filename = "files/" + file.name
        const uploadParams = {
          Bucket:  this.$store.state.bucket,
          Key: filename,
          Body: file
        };

        // const target = { Bucket, Key, Body };
        try {
          this.$store.commit("setState", { name:"uploadPercent", value:"0"})
          const parallelUploads3 = new UploadMulti({
            client: new S3Client({ region: this.$store.state.region,  credentials: this.$store.state.credentials  }),
            queueSize: 2, // optional concurrency configuration
            partSize: store.state.uploadPartSize, // optional size of each part
            leavePartsOnError: false, // optional manually handle dropped parts
            params: uploadParams
          });

          parallelUploads3.on("httpUploadProgress", (progress) => {
            let percent = ((progress.loaded/progress.total)*100).toFixed(2)
            if ( percent != 100) {
              this.$store.commit("setStatus", `Uploading: ${percent}%`)
              this.$store.commit("setState", { name:"uploadPercent", value: percent.toString()})
            }
            else {
              this.$store.commit("setStatus", `Upload Complete`)
              this.$store.commit("setState", { name:"uploadPercent", value: "100"})
            }
          });
          await parallelUploads3.done();
        } catch (e) {
          console.log(e);
        }

        this.uploadOngoing = false
        this.$store.state.toastMessage = `Sucessfully uploaded ${filename} file.`
        bsAlert.show();
        await this.listObjects() 
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
    listMultipart: async function(){
      // let bsAlert = new Toast( document.getElementById('liveToast') );  
      const s3Client = new S3Client({
          region: this.$store.state.region,
          credentials: this.$store.state.credentials
        });
      // let command = new ListMultipartUploadsCommand ({ Bucket:  this.$store.state.bucket, Prefix: "files"});
      let command = new ListMultipartUploadsCommand ({ Bucket:  this.$store.state.bucket});
      let result = await s3Client.send(command)
      return result.Uploads
      // .then((result) =>{
      //   console.log("Success", result)
      // })
      // .catch((result) =>{
      //   this.$store.state.toastMessage = `S3 multipart refresh failed!`
      //   bsAlert.show();
      //   console.log("Error",result)
      // })
    },
    listMultipartKey: async function(Key,UploadId){
      // let bsAlert = new Toast( document.getElementById('liveToast') );  
      const  s3Client = new S3Client({
          region: this.$store.state.region,
          credentials: this.$store.state.credentials
        });
      // let upload = result.Uploads[1]
      // let key = upload.Key
      // let uploadId = upload.UploadId
      let command2 = new ListPartsCommand({ Bucket:  this.$store.state.bucket, Key: Key, UploadId: UploadId});
      const response = await s3Client.send(command2);
      return response

      // .then((result) =>{
      //   console.log("Success", result)
      // })
      // .catch((result) =>{
      //   this.$store.state.toastMessage = `S3 multipart refresh failed!`
      //   bsAlert.show();
      //   console.log("Error",result)
      // })
    },
    uploadMultiResume : async function () {

      let store = this.$store
      let files = store.state.inputS3Upload.values.s3fileupload
      if (files?.length){
        const file = files[0];
        const filename = "files/" + file.name
        const uploadParams = {
          Bucket:  this.$store.state.bucket,
          Key: filename,
          Body: file
        };
        let UploadId  = null
        let multiParts = await this.listMultipart()
        for (let index = 0; index < multiParts.length; index++) {
          const element = multiParts[index];
          if (element.Key == uploadParams.Key) {
            console.log("MATCH", element.Key)
            UploadId = element.UploadId
          } else {
            console.log("NOMATCH", element.Key)
          }       
        }  
        console.log(UploadId)
        let multiPart = await this.listMultipartKey(uploadParams.Key, UploadId)

        let input = {
          Body : uploadParams.Body,
          Bucket : uploadParams.Bucket,
          Key: uploadParams. Key,
          Partnumber: multiPart.NextPartNumberMarker,
          UploadId: multiPart.UploadId

        }
        console.log(input)

        // const target = { Bucket, Key, Body };
        try {
          const s3Client = new S3Client({
            region: this.$store.state.region,
            credentials: this.$store.state.credentials
          });

          const command = new UploadPartCommand({ Body: input});
          const response = await s3Client.send(command);
          console.log(response)
        } catch (e) {
          console.log(e);
        }


      }
      else{
        this.$store.state.toastMessage = `No file selected for upload!`
      }

    },    
  },
  mounted: async function () {
    console.log("Mounted:", this.name)
    let uploads = await this.checkExistingMultipartUploads()
    if ( uploads.length > 0 ) {
      this.modalTitle = "Existing multi-part upload parts found!"
      this.modalMessage = uploads.join("\n")
      this.myModal = new Modal(document.getElementById('exampleModal'));
      this.myModal.show();
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
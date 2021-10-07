<template>
  <div class="d-flex flex-column">
    <div v-if="uploadOngoing" class="d-flex justify-content-center">
      <div>
        <span class="h3"> Uploading: {{$store.state.uploadPercent}}% Complete</span>
      </div>
    </div>
    <div v-if="uploadOngoing" class="progress">
      <div class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar" :aria-valuenow="$store.state.uploadPercent" aria-valuemin="0" aria-valuemax="100" :style="'width: '+$store.state.uploadPercent+'%'">{{$store.state.uploadPercent}}%</div>
    </div>
    <InputForm v-if="$store.state.credentials && !uploadOngoing" :name="$store.state.inputS3Upload.name" class="border border-2 rounded-3 p-2 d-flex overflow-auto">
      <template v-slot:footer>
        <!-- <button class="btn btn-primary me-1" data-bs-toggle="modal" data-bs-target="#clipboardModal">Clipboard</button>        
        <button class="btn btn-primary me-1" @click='listObjects()'>Refresh</button> -->
        <button class="btn btn-primary" @click='uploadMulti()'><span v-if='uploadOngoing' class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>Upload</button>
      </template>      
    </InputForm>
  </div> 
</template>

<script>
import InputForm from './InputForm.vue'
import { S3Client, UploadPartCommand, ListMultipartUploadsCommand, ListPartsCommand , ListObjectsCommand, GetObjectCommand, PutObjectCommand, DeleteObjectCommand   } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { Upload as UploadMulti } from "@aws-sdk/lib-storage";
import { add } from 'date-fns'
import { Toast } from "bootstrap" ;
import { saveAs } from 'file-saver';

export default {
  name: 'Upload',
  components: {
    InputForm
  },
  props: {
    name: {
          type: String,
          default: "Upload"
        }  
  },
  data: function (){
    return {
      search: "",
      // buckets: [{Key: 1},{Key: 2},{Key: 3}]
      buckets: [],
      uploadOngoing: false,
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
      console.log(response)
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

  },
  mounted: async function () {
    console.log("Mounted:", this.name)  
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
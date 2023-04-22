<script setup>
import WindowInput from "./WindowInput.vue";
import {  reactive, onMounted, onBeforeMount, watch } from 'vue'
import { store } from '../store.js'
import { S3, S3Client, ListObjectsCommand, GetObjectCommand, DeleteObjectCommand} from "@aws-sdk/client-s3";
import { Upload as UploadMulti } from "@aws-sdk/lib-storage";
import { add , format } from 'date-fns'
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

let state = reactive({ 
  text: "", 
  id: null,
  files : [],
  uploadPercent: 1,
  uploadOngoing: false,
})


async function signedUrl(key){
  let credentials = store.aws.credentials
  let region      = store.inputs.awsConfig.region.value
  let bucket      = store.inputs.awsConfig.bucket.value  
  const s3Client = new S3Client({
    region: region,
    credentials: credentials
  });
  const command = new GetObjectCommand({ Bucket:  bucket, Key: key});
  const url = await getSignedUrl(s3Client, command, { expiresIn: 3600 });
  console.log(url)
  return url
}

async function listObjects(){
  let credentials = store.aws.credentials
  let region      = store.inputs.awsConfig.region.value
  let bucket      = store.inputs.awsConfig.bucket.value
  let file_prefix =  "files"

  const s3Client = new S3Client({
      region: region,
      credentials: credentials
    });
  let command = new ListObjectsCommand({ Bucket: bucket, Prefix: file_prefix});
  let result = await s3Client.send(command)
  state.files = result.Contents ? result.Contents : []

  for (let index = 0; index < state.files.length; index++) {
      let expireDate = add(state.files[index].LastModified, {days: 2})
      expireDate.setUTCHours(0, 0, 0, 0)
      state.files[index].expireDate = format( expireDate, "pp PP" )
      state.files[index].LastModified = format( state.files[index].LastModified, "pp PP" )
      
    }  
}

async function download (key){
    try {
      let url = await signedUrl(key)
      let filename = key.split("/").pop()
      console.log("Download",filename)
      const link = document.createElement('a');
      link.href = url;
      link.download  = filename;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    } 
    catch (error) {
      console.log("Error",error)
    }
  }


function readFileToConsole(file){
  const reader = new FileReader();
  reader.onload = (evt) => {
    console.log(evt.target.result);
  };
  reader.readAsText(file)  
}

async function upload(file){
  try {
    state.uploadOngoing = true
    state.uploadPercent = 0
    let credentials = store.aws.credentials
    let region      = store.inputs.awsConfig.region.value
    let bucket      = store.inputs.awsConfig.bucket.value
    let uploadPartSize = "5242880"
    let file_prefix =  "files"
    const config = { region: region,  credentials: credentials  }

    const uploadParams = {
      Bucket:  bucket,
      Key: file_prefix + "/" + file.name,
      Body: file
    };

    const parallelUploads3 = new UploadMulti({
      client: new S3(config) || new S3Client(config),
      queueSize: 2, // optional concurrency configuration
      partSize: uploadPartSize, // optional size of each part
      leavePartsOnError: false, // optional manually handle dropped parts
      params: uploadParams
    });    

    parallelUploads3.on("httpUploadProgress", (progress) => {
      let percent = ((progress.loaded/progress.total)*100).toFixed(2)
      if ( percent != 100) {
        // this.$store.commit("setStatus", `Uploading: ${percent}%`)
        state.uploadPercent = percent.toString()
      }
      else {
        // this.$store.commit("setStatus", `Upload Complete`)
        state.uploadPercent = "100"
        state.uploadOngoing = false
      }
    });  

    return parallelUploads3.done()

  } catch (e) {
    console.log(e); 
    state.uploadOngoing = false
  }
}

async function deleteKey (key) {
  let credentials = store.aws.credentials
  let region      = store.inputs.awsConfig.region.value
  let bucket      = store.inputs.awsConfig.bucket.value
   
  const s3Client = new S3Client({
    region: region,
    credentials: credentials
  });

  let params = { Bucket:  bucket, Key: key}
  try {
    await s3Client.send(new DeleteObjectCommand(params));
    await listObjects()
  }catch (err) {
    console.log(err)
    await listObjects()
  }
}

function uploadStop(file){
  state.uploadOngoing = false
  console.log(file)
}

// Watch if a file is selected then start upload & refresh
watch( 
  () => store.inputs.awsUpload.file.value, 
  file => {
    if (file){
      upload(file)
      .then(listObjects)
      .then( () =>store.inputs.awsUpload.file.value = null )
    }
  }
)

onBeforeMount(()=>{
  state.id = crypto.randomUUID()
})

onMounted( async () => {
  console.log(`Mounted: AWSFiles`)
  listObjects()
})


</script>
 
<template>

  <div class="d-flex flex-column flex-fill">

    <!-- UPLOAD OPTION -->
    <div v-if="!state.uploadOngoing" class="d-flex flex-column align-items-center justify-content-center">
      <WindowInput id="awsUpload"></WindowInput>
    </div>
    
    <!-- UPLOADING -->
    <div v-if="state.uploadOngoing" class="d-flex align-items-center justify-content-center mt-2 mb-2">
        <span class="h3 m-0"> {{state.uploadPercent}}% Complete</span>
        <button type="button" class="ms-2 btn btn-danger" @click="uploadStop">Stop</button>
    </div>
    <div v-if="state.uploadOngoing" class="progress">
      <div class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar" :aria-valuenow="state.uploadPercent" aria-valuemin="0" aria-valuemax="100" :style="'width: '+state.uploadPercent+'%'">{{state.uploadPercent}}%</div>
    </div>    

    <!-- FILELIST -->
    <table class="table">
      <thead>
        <tr>
          <th scope="col">File</th>
          <th scope="col">Size</th>
          <th scope="col" class="d-none d-md-table-cell">Last Modified</th>
          <th scope="col" class="d-none d-sm-table-cell">Expire on</th>
          <th scope="col">Action</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="file in state.files" :key="file.Key" >
          <!-- <td><a href="#" @click="test()">{{file.Key}}</a></td> -->
          <td><a href="#" @click="download(file.Key)">{{file.Key.split("/").pop()}}</a></td>
          <td>{{file.Size}}</td>
          <td class="d-none d-md-table-cell">{{file.LastModified}}</td>
          <td class="d-none d-sm-table-cell">{{file.expireDate}}</td>
          <td>
            <div class="btn-group">
              <button type="button" class="btn btn-small btn-outline-secondary" @click="deleteKey(file.Key)" data-bs-toggle="tooltip" data-bs-placement="bottom" title="Delete">
                <i class="bi-trash-fill" ></i>
              </button>
              <button type="button" class="btn btn-small btn-outline-secondary" @click="signedUrl(file.Key)" data-bs-toggle="tooltip" data-bs-placement="bottom" title="Pre-signed URL to clipboard">
                <i class="bi-pen-fill" ></i>
              </button>
            </div>
          </td>              
        </tr>
      </tbody>
    </table>

  </div>  
  
</template>

<style scoped>

</style>
<script setup>
import { onMounted, reactive} from "vue";
import { store } from "../store.js"
import { Toast } from 'bootstrap'
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";

function message(msg){
  store.toastMessage = msg
  var bsAlert = new Toast( document.getElementById('liveToast') );//inizialize it      
  bsAlert.show();//show it   
}

let state = reactive({ 
  text: ""
})

function copy(){
  navigator.clipboard.writeText(store.aws.clipboard)
  message("content was copied to OS clipboard!")
}

function presignedWebSite(){
  state.text = `${window.location.origin}/index.html?idToken=${store.aws.idToken}`
}


function guestAccess() {
  const min = 10000000; // Minimum value for a 8-digit number
  const max = 99999999; // Maximum value for a 8-digit number
  const pin = Math.floor(Math.random() * (max - min + 1) + min).toString(); // Generate a random number between min and max, convert it to a string
  const region = store.inputs.awsConfig.region.value
  const bucket = store.inputs.awsConfig.bucket.value
  const credentials = store.aws.credentials
  const body = pin

  const s3Client = new S3Client({
    region: region,
    credentials: credentials
  });

  // Define the parameters for the text file upload
  const uploadParams = {
    Bucket: bucket,
    Key: "files/guestpin.txt",
    Body: body,
    ContentType: "text/html"
  };

  // Upload the file to the S3 bucket
  const command = new PutObjectCommand(uploadParams);
  s3Client.send(command).then(
    (data) => {
      const msg = `Guest access was activated with pin:${pin}`
      message(msg)
      state.text = msg
    },
    (err) => {
      console.log("Error uploading file:", err);
      message(err.message)
    }
  );



}

async function presignedUpload(os){
  const credentials = store.aws.credentials
  const region      = store.inputs.awsConfig.region.value
  const bucket = store.inputs.awsConfig.bucket.value
  const fileKey = 'files/upload.zip';
  const expirationTime = 3600;

  const s3Client = new S3Client({
    region: region,
    credentials: credentials
  });
  
  // Create a PutObjectCommand with the S3 bucket name and file key
  const putObjectCommand = new PutObjectCommand({
    Bucket: bucket,
    Key: fileKey
  });
  // Generate a presigned URL for the PutObjectCommand
    const presignedUrl = await getSignedUrl(s3Client, putObjectCommand, {
    // expiresIn: expirationTime,
    signingArguments: { signQuery: { SignatureVersion: "v4" } },
    });
  state.text = os == 'unix' 
  ? `curl --progress-bar -X PUT -T upload.zip '${presignedUrl}' | cat`
  : `C:\\windows\\system32\\curl.exe -v -X PUT -T upload.zip '${presignedUrl}' | cat`
}

onMounted(() => {
    console.log(`Mounted: ModalAWSShare`)
});

</script>

<template>
    <!-- Modal -->
    <div class="modal fade" id="modalAWSShare" tabindex="-1" aria-labelledby="modalAWSShareLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header bg-dark text-white">
            <h5 class="modal-title" id="modalAWSShareLabel">Site Access Sharing</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div class="list-group">
              <button @click="presignedWebSite" class="list-group-item list-group-item-secondary list-group-item-action">
                Pre-signed link with 1 hour expiration for this website
              </button>
              <button @click="guestAccess" class="list-group-item list-group-item-secondary list-group-item-action">
                One-time password for guest user access
              </button>
              <button @click="presignedUpload('unix')" class="list-group-item list-group-item-secondary list-group-item-action">
                CLI curl upload for a single file (upload.zip) - Unix 
              </button>
              <button @click="presignedUpload('windows')" class="list-group-item list-group-item-secondary list-group-item-action">
                CLI curl upload for a single file (upload.zip) - Windows
              </button>
              <div class="d-flex flex-column flex-fill mt-3">
                <textarea 
                  class="form-control d-flex flex-fill" 
                  name="clipboardTextarea" 
                  id="clipboardTextarea" 
                  cols="30" rows="10" 
                  placeholder="Secret is placed here..."
                  v-model="state.text">
                </textarea>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-primary" @click="copy">Copy</button>
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>
</template>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
</style>
<script setup>
import { onMounted, reactive} from "vue";
import { store } from "../store.js"
import { Toast } from 'bootstrap'
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { S3Client, PutObjectCommand, GetObjectCommand } from "@aws-sdk/client-s3";

function message(msg){
  store.toastMessage = msg
  var bsAlert = new Toast( document.getElementById('liveToast') );
  bsAlert.show();
}

let state = reactive({
  text: "",
  downloadFilename: "upload.zip"
})

function copy(){
  navigator.clipboard.writeText(state.text)
  message("Copied to clipboard!")
}

async function presignedDownload(os){
  const credentials = store.aws.credentials
  const region      = store.inputs.awsConfig.region.value
  const bucket      = store.inputs.awsConfig.bucket.value
  const fileKey     = 'files/upload.zip';
  const filename    = state.downloadFilename || 'upload.zip';

  const s3Client = new S3Client({
    region,
    credentials,
    forcePathStyle: true,
    endpoint: "https://s3.amazonaws.com",
  });

  const presignedUrl = await getSignedUrl(s3Client, new GetObjectCommand({ Bucket: bucket, Key: fileKey }));
  state.text = os === 'unix'
    ? `curl --progress-bar -o '${filename}' '${presignedUrl}'`
    : `C:\\windows\\system32\\curl.exe --progress-bar -o "${filename}" "${presignedUrl}"`
}

async function presignedUpload(os){

  const credentials = store.aws.credentials
  const region      = store.inputs.awsConfig.region.value
  const bucket      = store.inputs.awsConfig.bucket.value
  const fileKey     = 'files/upload.zip';

  const s3Client = new S3Client({
    region,
    credentials,
    forcePathStyle: true,
    endpoint: "https://s3.amazonaws.com",
  });

  const presignedUrl = await getSignedUrl(s3Client, new PutObjectCommand({ Bucket: bucket, Key: fileKey }));
  state.text = os === 'unix'
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
              <button @click="presignedUpload('unix')" class="list-group-item list-group-item-secondary list-group-item-action">
                CLI curl upload for a single file (upload.zip) - Unix
              </button>
              <button @click="presignedUpload('windows')" class="list-group-item list-group-item-secondary list-group-item-action">
                CLI curl upload for a single file (upload.zip) - Windows
              </button>
              <div class="list-group-item">
                <input class="form-control form-control-sm" v-model="state.downloadFilename" placeholder="Save as filename (e.g. myfile.zip)"/>
              </div>
              <button @click="presignedDownload('unix')" class="list-group-item list-group-item-secondary list-group-item-action">
                CLI curl download for a single file (upload.zip) - Unix
              </button>
              <button @click="presignedDownload('windows')" class="list-group-item list-group-item-secondary list-group-item-action">
                CLI curl download for a single file (upload.zip) - Windows
              </button>
              <div class="d-flex flex-column flex-fill mt-3">
                <textarea
                  class="form-control d-flex flex-fill"
                  cols="30" rows="10"
                  placeholder="Generated command appears here..."
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

<style scoped>
</style>

<script setup>
import { onMounted, reactive } from "vue";
import { store } from '../store.js'
import { S3Client, ListObjectsCommand } from "@aws-sdk/client-s3";
import { Toast, Modal } from "bootstrap";
import WindowInput from "./WindowInput.vue";

let state = reactive({
  initComplete: false,
  loggingIn: false,
})

function message(msg){
  store.toastMessage = msg
  var bsAlert = new Toast(document.getElementById('liveToast'));
  bsAlert.show();
}

function aws_config(){
  let elem = document.getElementById("modalAWSConfig")
  let modal = new Modal(elem)
  modal.show()
}

async function login(){
  const accessKeyId     = store.inputs.awsLogin.accessKeyId.value
  const secretAccessKey = store.inputs.awsLogin.secretAccessKey.value
  if (!accessKeyId || !secretAccessKey) {
    message("Please enter Access Key ID and Secret Access Key")
    return;
  }

  state.loggingIn = true
  const region = store.inputs.awsConfig.region.value
  const bucket = store.inputs.awsConfig.bucket.value

  try {
    const staticCredentials = { accessKeyId, secretAccessKey }
    const s3Client = new S3Client({
      region,
      credentials: staticCredentials,
      forcePathStyle: true,
    })
    await s3Client.send(new ListObjectsCommand({ Bucket: bucket, Prefix: "files", MaxKeys: 1 }))

    // Store as async provider function so both S3Client and WebSocket signing work
    store.aws.credentials = async () => staticCredentials
    store.aws.status = "Logged in"
  } catch (err) {
    message(`Login failed: ${err.message}`)
    store.aws.status = "Login failure"
  } finally {
    state.loggingIn = false
  }
}

async function loadConfig() {
  if (localStorage.getItem("awsConfig")) {
    try {
      const awsConfig = JSON.parse(localStorage.getItem("awsConfig"))
      store.inputs.awsConfig.bucket.value         = awsConfig.bucket
      store.inputs.awsConfig.region.value         = awsConfig.region
      store.inputs.awsConfig.userPoolId.value     = awsConfig.userPoolId
      store.inputs.awsConfig.clientId.value       = awsConfig.clientId
      store.inputs.awsConfig.identityPoolId.value = awsConfig.identityPoolId
      store.inputs.awsConfig.websocket_api.value  = awsConfig.websocket_api
      store.inputs.awsConfig.auth_proxy_url.value = awsConfig.auth_proxy_url
      store.inputs.awsConfig.auth_login_url.value = awsConfig.auth_login_url
    } catch (error) {
      message("Invalid local configuration! Reverting to default config...")
      localStorage.removeItem("awsConfig")
      return false;
    }
  } else {
    const url = new URL(window.location.href);
    const directoryPath = url.pathname.split('/').slice(0, -1).join('/');
    const configUrl = `${directoryPath}/awsconfig.json`
    const res = await fetch(configUrl);
    if (res.ok) {
      const awsConfig = await res.json().catch(() => null);
      store.inputs.awsConfig.bucket.value         = awsConfig.bucket
      store.inputs.awsConfig.region.value         = awsConfig.region
      store.inputs.awsConfig.userPoolId.value     = awsConfig.userPoolId
      store.inputs.awsConfig.clientId.value       = awsConfig.clientId
      store.inputs.awsConfig.identityPoolId.value = awsConfig.identityPoolId
      store.inputs.awsConfig.websocket_api.value  = awsConfig.websocket_api
      store.inputs.awsConfig.auth_proxy_url.value = awsConfig.auth_proxy_url
      store.inputs.awsConfig.auth_login_url.value = awsConfig.auth_login_url
    } else {
      message(`${res.statusText} - ${configUrl}`)
      return false;
    }
  }
  return true;
}

onMounted(async () => {
  await loadConfig()
  state.initComplete = true;
});
</script>

<template>
  <div class="d-flex flex-column justify-content-center align-items-center">
    <div v-if="state.initComplete">
      <div class="card">
        <div class="card-header bg-dark text-white">
          Login
          <span class="float-end" @click="aws_config" style="cursor:pointer">
            <i class="bi bi-gear"></i>
          </span>
        </div>
        <div class="card-body p-4">
          <WindowInput id="awsLogin"/>
          <div class="d-flex justify-content-center mt-2">
            <button class="btn btn-primary px-4" @click="login" :disabled="state.loggingIn">
              <span v-if="state.loggingIn" class="spinner-border spinner-border-sm me-2" role="status"></span>
              <i v-else class="bi bi-box-arrow-in-right me-2"></i>Sign In
            </button>
          </div>
        </div>
      </div>
    </div>
    <div v-else class="spinner-border" style="width: 5rem; height: 5rem;" role="status">
      <span class="visually-hidden">Loading...</span>
    </div>
  </div>
</template>

<style scoped>
</style>

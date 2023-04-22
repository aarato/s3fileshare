<script setup>
import { onMounted, reactive, ref, computed} from "vue";
import { store } from "../store.js"
import WindowInput from "./WindowInput.vue";
import { CognitoIdentityClient } from "@aws-sdk/client-cognito-identity";
import { fromCognitoIdentityPool } from "@aws-sdk/credential-provider-cognito-identity";
// var AmazonCognitoIdentity = require('amazon-cognito-identity-js');
import {	AuthenticationDetails, CognitoUserPool, CognitoUser } from 'amazon-cognito-identity-js';
import { STSClient, GetCallerIdentityCommand } from "@aws-sdk/client-sts"
import { getUnixTime } from 'date-fns'
import { Modal, Toast } from 'bootstrap'

function message(msg){
  store.toastMessage = msg
  var bsAlert = new Toast( document.getElementById('liveToast') );//inizialize it      
  bsAlert.show();//show it   
}


async function download(){
  const configUrl =  `https://${store.inputs.awsConfig.bucket.value}.s3.${store.inputs.awsConfig.region.value}.amazonaws.com/awsconfig.json`
  const res = await fetch(configUrl);
  if (res.ok) {
    const awsConfig = await res.json().catch(()=> null);
    store.inputs.awsConfig.bucket.value = awsConfig.bucket
    store.inputs.awsConfig.region.value = awsConfig.region
    store.inputs.awsConfig.userPoolId.value = awsConfig.userPoolId
    store.inputs.awsConfig.clientId.value = awsConfig.clientId
    store.inputs.awsConfig.identityPoolId.value = awsConfig.identityPoolId
    store.inputs.awsConfig.websocket_api.value = awsConfig.websocket_api
  }
  else{
    message(`${res.statusText} - ${configUrl}`)
    return;
  }  
}


function save(){
  const awsConfig = {}
  awsConfig.bucket = store.inputs.awsConfig.bucket.value
  awsConfig.region = store.inputs.awsConfig.region.value
  awsConfig.userPoolId = store.inputs.awsConfig.userPoolId.value
  awsConfig.clientId = store.inputs.awsConfig.clientId.value
  awsConfig.identityPoolId = store.inputs.awsConfig.identityPoolId.value
  awsConfig.websocket_api = store.inputs.awsConfig.websocket_api.value 
  localStorage.setItem("awsConfig",JSON.stringify(awsConfig))
}


onMounted(() => {
    console.log(`Mounted: ModalAWSConfig`)
});

</script>

<template>
    <!-- Modal -->
    <div class="modal fade" id="modalAWSConfig" tabindex="-1" aria-labelledby="modalAWSConfigLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="modalAWSConfigLabel">AWS settings</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <WindowInput id="awsConfig"/>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="download">Download</button>
            <button type="button" class="btn btn-secondary" @click="save">Save</button>
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>
</template>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
</style>
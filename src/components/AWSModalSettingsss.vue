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

function connect(){
}

function disconnect(){
}

function save(){
}

async function getIdToken () {
  const username        = store.inputs.awsSettings.username.value
  const password        = store.inputs.awsSettings.password.value
  const userPoolId      = store.inputs.awsSettings.userPoolId.value
  const clientId        = store.inputs.awsSettings.clientId.value

  var authenticationDetails = new AuthenticationDetails({
      Username : username,
      Password : password,
  });

  var userPool = new CognitoUserPool({ 
      UserPoolId : userPoolId,
      ClientId : clientId
  });
  
  var cognitoUser = new CognitoUser({
      Username : username,
      Pool : userPool
  });

  // Return idToken
  const t = await new Promise((resolve, reject) => {
    cognitoUser.authenticateUser(authenticationDetails, {
        onSuccess: function (result) {
            // var accessToken = result.getAccessToken().getJwtToken();
            /* Use the idToken for Logins Map when Federating User Pools with identity pools or when passing through an Authorization Header to an API Gateway Authorizer */
            let idToken = result.idToken.jwtToken;
            localStorage.setItem( "idToken", idToken)
            localStorage.setItem( "idToken_expiration", getUnixTime(Date.now()) + 3600) // 1 hour expiration
            resolve(idToken)
        },
        onFailure: function(err) {
            store.aws.idToken = ""    
            localStorage.removeItem( "idToken", idToken)
            localStorage.removeItem( "idToken_expiration", getUnixTime(Date.now()) + 3600) // 1 hour expiration
            console.log(err);
            resolve(null)
        },
    });    
  });
  return t;
}

async function getCredentials () {  
  const region          = store.inputs.awsSettings.region.value
  const userPoolId      = store.inputs.awsSettings.userPoolId.value
  const identityPoolId  = store.inputs.awsSettings.identityPoolId.value

  const currentTime = getUnixTime(Date.now()) 
  const idToken = localStorage.getItem("idToken")
  const idToken_expiration = parseInt( localStorage.getItem("idToken_expiration") )

  if ( idToken && idToken_expiration > currentTime ) {
    store.aws.idToken = idToken
    store.inputs.awsSettings.idToken.value = idToken
    const credentials = fromCognitoIdentityPool({
        client: new CognitoIdentityClient({region:region}),
        identityPoolId: identityPoolId,
        logins: { [`cognito-idp.${region}.amazonaws.com/${userPoolId}`] : idToken },
    })
   
    const config = {
      region: region,
      credentials: credentials
    }   
    
    const client = new STSClient(config);
    const input = {};
    const command = new GetCallerIdentityCommand(input);
    const response = await client.send(command);
    store.inputs.awsSettings.account.value = response.Account
    store.inputs.awsSettings.userid.value = response.UserId
    store.inputs.awsSettings.arn.value = response.Arn
    let creds = await credentials()
    store.inputs.awsSettings.accessKeyId.value = creds.accessKeyId
    store.inputs.awsSettings.secretAccessKey.value = creds.secretAccessKey   
    store.aws.credentials = credentials
    store.aws.status = "Logged in"
  } else {
    localStorage.removeItem("idToken");
    localStorage.removeItem("idToken_expiration");
    store.aws.credentials = null
    store.aws.status = "Login failure"    
  }

}

async function login(){
  let t = await getIdToken()
  let c = await getCredentials()
}

async function logout(){
  localStorage.removeItem("idToken");
  localStorage.removeItem("idToken_expiration");
  store.aws.credentials = null
}

const connected = computed(() => store.aws && store.aws.credentials ? true : false)

onMounted(() => {
    console.log(`Mounted: ModalAWSettings`)
});

</script>

<template>
    <!-- Modal -->
    <div class="modal fade" id="modalAWSSettings" tabindex="-1" aria-labelledby="modalAWSSettingsLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="modalAWSSettingsLabel">AWS settings</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <WindowInput id="awsSettings"/>
          </div>
          <div class="modal-footer">
            <button v-if="!connected" type="button" class="btn btn-secondary" @click="login">Login</button>
            <button v-if="connected" type="button" class="btn btn-secondary" @click="logout" >Logout</button>
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
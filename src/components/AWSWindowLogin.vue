<script setup>
import { onMounted } from "vue";
import WindowInput from "./WindowInput.vue";
import { store } from '../store.js'
import { CognitoIdentityClient } from "@aws-sdk/client-cognito-identity";
import { fromCognitoIdentityPool } from "@aws-sdk/credential-provider-cognito-identity";
import {	AuthenticationDetails, CognitoUserPool, CognitoUser } from 'amazon-cognito-identity-js';
import { STSClient, GetCallerIdentityCommand } from "@aws-sdk/client-sts"
import { getUnixTime } from 'date-fns'
import { Toast, Modal } from "bootstrap" ;

function message(msg){
  store.toastMessage = msg
  var bsAlert = new Toast( document.getElementById('liveToast') );//inizialize it      
  bsAlert.show();//show it   
}

function aws_config(){
  let elem = document.getElementById("modalAWSConfig")
  let modal = new Modal(elem)
  modal.show()    
}

async function getIdToken () {
  const username        = store.inputs.awsLogin.username.value
  const password        = store.inputs.awsLogin.password.value
  const userPoolId      = store.inputs.awsConfig.userPoolId.value
  const clientId        = store.inputs.awsConfig.clientId.value

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
            localStorage.removeItem( "idToken")
            localStorage.removeItem( "idToken_expiration")
            message(err.message)
            console.log(err);
            resolve(null)
        },
    });    
  });
  return t;
}


async function getCredentials () {  
  const region          = store.inputs.awsConfig.region.value
  const userPoolId      = store.inputs.awsConfig.userPoolId.value
  const identityPoolId  = store.inputs.awsConfig.identityPoolId.value

  const idToken = localStorage.getItem("idToken")
  if ( !idToken ) return;
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
  const response = await client.send(command).catch(()=> null);;   


  if ( response ) {
    store.aws.idToken = idToken
    // store.inputs.awsSettings.idToken.value = idToken
    // store.inputs.awsSettings.account.value = response.Account
    // store.inputs.awsSettings.userid.value = response.UserId
    // store.inputs.awsSettings.arn.value = response.Arn
    let creds = await credentials()
    // store.inputs.awsSettings.accessKeyId.value = creds.accessKeyId
    // store.inputs.awsSettings.secretAccessKey.value = creds.secretAccessKey   
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
  console.log("Login submitted")
  await getIdToken()
  await getCredentials()
}


onMounted( async () => {
  if ( localStorage.getItem("awsConfig") )
    try {
      const awsConfig = JSON.parse(localStorage.getItem("awsConfig"))
      store.inputs.awsConfig.bucket.value = awsConfig.bucket
      store.inputs.awsConfig.region.value = awsConfig.region
      store.inputs.awsConfig.userPoolId.value = awsConfig.userPoolId
      store.inputs.awsConfig.clientId.value = awsConfig.clientId
      store.inputs.awsConfig.identityPoolId.value = awsConfig.identityPoolId
      store.inputs.awsConfig.websocket_api.value = awsConfig.websocket_api
    } catch (error) {
      message("Invalid local configuration! Reverting to default config...")
      localStorage.removeItem("awsConfig")
      return;
    }
  else{
    const url = new URL(window.location.href);
    const configUrl = `${url.origin}/awsconfig.json`
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
  const url = new URL(window.location.href)
  const idToken = url.searchParams.get("idToken")
  if( idToken ) {
    localStorage.setItem("idToken",idToken)
    url.searchParams.delete("idToken")
    window.location.href=url.href
  }else{
    getCredentials()
  }
  
});
</script>

<template> 
  <div  class="d-flex flex-column justify-content-center align-items-center" >
    <div>
        <div class="card">
          <div class="card-header bg-dark text-white">
            Login
            <span class="float-end" @click="aws_config">
              <i class="bi bi-gear"></i>
            </span>
            
          </div>
          <div class="card-body">
            <WindowInput id="awsLogin" @submit="login"/>
            <button type="submit" class="btn btn-primary float-end" @click="login" >Submit</button>
          </div>
        </div>      
    </div>
  </div> 
</template>

<style scoped>
</style>

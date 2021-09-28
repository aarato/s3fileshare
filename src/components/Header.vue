<template>
<div class="pt-1 pb-1 bg-dark text-white">
  <div class="d-flex align-items-center justify-content-between">
  <div class="form-floating ms-1">
      <input readonly type="text" class="form-control bg-dark text-white" id="floatingStatus" placeholder="Status" :value="$store.state.status">
      <label for="floatingStatus">Current Status</label>
  </div>        
  <div>
      <button 
        v-if = "$store.state.idToken"
        type="button" 
        class="btn btn-outline-light me-1"
        @click="logout()"
      >Logout
      </button>
      <button 
        v-else
        type="button" 
        class="btn btn-outline-light me-1"
        data-bs-toggle="modal" 
        data-bs-target="#loginModal"
      >Login
      </button>
  </div>
  </div>

  <!-- Modal -->
  <div class="modal fade" id="loginModal" tabindex="-1" aria-labelledby="loginModalLabel" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title text-dark" id="loginModalLabel">Login</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body text-dark">
          <InputForm :name="name"></InputForm>
        </div>
        <div class="modal-footer">
          <!-- <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button> -->
          <button type="button" class="btn btn-primary" data-bs-dismiss="modal" @click="login" >Login</button>
        </div>
      </div>
    </div>
  </div>    

</div>  
</template>
<script>
import InputForm from './InputForm.vue'
var AmazonCognitoIdentity = require('amazon-cognito-identity-js');
import { CognitoIdentityClient } from "@aws-sdk/client-cognito-identity";
import { fromCognitoIdentityPool } from "@aws-sdk/credential-provider-cognito-identity";

export default {
  name: 'Headers',
  components: {
    InputForm
  },
  data() {
    return {
      name: "inputLogin"
    }
  },
  computed: {
      count (){
          return this.$store.state.count
      }
      // ,
      // logged_in () {
      //   return ( this.$store.statecredentials)
      // }
  },  
  methods:{
    logout: function(){
      window.location.reload()
    },
    login: async function () {
      let store = this.$store
      let input  = this.$store.state[this.name].values
      store.commit("setState", {name: "username", value : input.username })
      store.commit("setState", {name: "password", value : input.password })

      const username        = store.state.username
      const password        = store.state.password
      const region          = store.state.region
      const userPoolId      = store.state.userPoolId
      const clientId        = store.state.clientId
      const identityPoolId  = store.state.identityPoolId

      var authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails({
          Username : username,
          Password : password,
      });
    
      var userPool = new AmazonCognitoIdentity.CognitoUserPool({ 
          UserPoolId : userPoolId,
          ClientId : clientId
      });
      
      var cognitoUser = new AmazonCognitoIdentity.CognitoUser({
          Username : username,
          Pool : userPool
      });
      
      cognitoUser.authenticateUser(authenticationDetails, {
          onSuccess: function (result) {
              // var accessToken = result.getAccessToken().getJwtToken();
              /* Use the idToken for Logins Map when Federating User Pools with identity pools or when passing through an Authorization Header to an API Gateway Authorizer */
              let idToken = result.idToken.jwtToken;
              let credentials = fromCognitoIdentityPool({
                  client: new CognitoIdentityClient({region:region}),
                  identityPoolId: identityPoolId,
                  logins: { [`cognito-idp.${region}.amazonaws.com/${userPoolId}`] : idToken },
              })
              store.commit("setState", {name: "idToken", value : idToken })
              store.commit("setState", {name: "credentials", value : credentials })
              store.commit("setState", {name: "status", value : "Logged in" })
          },
          onFailure: function(err) {
              store.commit("setState", {name: "idToken", value : "" })
              store.commit("setState", {name: "credentials", value : null })
              store.commit("setState", {name: "status", value : "Login failed" })
              console.log(err);
          },
      });

    }
  }, 
  mounted(){
    console.log("Mounted: Header ")
  }
}

</script>
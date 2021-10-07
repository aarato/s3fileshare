<template>
    <div class="d-flex flex-column flex-fill">
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
            <tr v-for="bucket in buckets" :key="bucket.Key" >
              <!-- <td><a href="#" @click="test()">{{bucket.Key}}</a></td> -->
              <td><a href="#" @click="download(bucket.Key)">{{bucket.Key.split("/").pop()}}</a></td>
              <td>{{bucket.Size}}</td>
              <td class="d-none d-md-table-cell">{{bucket.LastModified}}</td>
              <td class="d-none d-sm-table-cell">{{bucket.expireDate}}</td>
              <td>
                <div class="btn-group">
                  <button type="button" class="btn btn-small btn-outline-secondary" @click="deleteFile(bucket.Key)" data-bs-toggle="tooltip" data-bs-placement="bottom" title="Delete">
                    <i class="bi-trash-fill" ></i>
                  </button>
                  <button type="button" class="btn btn-small btn-outline-secondary" @click="signedURL(bucket.Key)" data-bs-toggle="tooltip" data-bs-placement="bottom" title="Pre-signed URL to clipboard">
                    <i class="bi-pen-fill" ></i>
                  </button>
                </div>
              </td>              
            </tr>
          </tbody>
        </table>
    </div>  
</template>

<script>
import { S3Client, ListObjectsCommand } from "@aws-sdk/client-s3";
import { add } from 'date-fns'
import { Toast } from "bootstrap" ;
import { toastMessage, GetSignedUrl, deleteKey } from "./helpers.js"

export default {
  name: 'Download',
  components: {
    
  },
  props: {
    name: {
          type: String,
          default: "Download"
        }  
  },
  data: function (){
    return {
      // buckets: [{Key: 1},{Key: 2},{Key: 3}]
      buckets: [],
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
    signedURL: async function(key){
      let url = await GetSignedUrl(key)
      navigator.clipboard.writeText(url)
      this.$store.state.clipboard = url
      toastMessage(`Pre-signed URL for ${key} copied to clipboard.`)
    },
    deleteFile: async function(key){
      await deleteKey(key)
      await this.listObjects()
    },
    download: async function(key){
      try {
        let url = await GetSignedUrl(key)
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
    this.listObjects()  
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
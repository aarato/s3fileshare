import store from "../store.js"
import { Toast } from "bootstrap" ;
// import { Upload } from "@aws-sdk/lib-storage";
import { 
    S3Client, 
    // UploadPartCommand, 
    // ListMultipartUploadsCommand, 
    // ListPartsCommand , 
    // ListObjectsCommand, 
    GetObjectCommand, 
    PutObjectCommand, 
    DeleteObjectCommand   
    } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

export{
    toastMessage,
    setStatusMessage,
    GetSignedUrl,
    deleteKey,
    getClipboard,
    saveClipboard
}


//
//  S3 HELPER FUNCTIONS
//

async function GetSignedUrl(key){
    const s3Client = new S3Client({
      region: store.state.region,
      credentials: store.state.credentials
    });
    const command = new GetObjectCommand({ Bucket:  store.state.bucket, Key: key});
    const url = await getSignedUrl(s3Client, command, { expiresIn: 3600 });
    return url
}

async function deleteKey(key) {
    const s3Client = new S3Client({
      region: store.state.region,
      credentials: store.state.credentials
    });
    let params = { Bucket:  store.state.bucket, Key: key}
    try {
        await s3Client.send(new DeleteObjectCommand(params));
        toastMessage(`Sucessfully deleted ${key}.`)
    }catch (err) {
        console.log(err)
        return alert(`There was an error deleting ${key}: `);      
    }
}

async function getClipboard(){
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
  }
  async function saveClipboard() {
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
  }



//
//  GENERAL HELPER FUNCTIONS
//
function toastMessage(message){
    var bsAlert = new Toast( document.getElementById('liveToast') );//inizialize it      
    store.state.toastMessage = message
    bsAlert.show();//show it 
}

function setStatusMessage(message){
    store.commit("setState", {name: "status", value : message })
}



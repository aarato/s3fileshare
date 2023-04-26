import { reactive } from 'vue'

export const store = reactive({
  aws:{
    credentials: null,
    idToken: null,
    status: "Disconnected",
    clipboard: "",
    awsWebSocketConnected: false,
    files : [],
    navView: "files" //Controls which view is shown on navbar
  },
  socket: null,
  toastMessage: "",
  textarea: "",
  loggedIn: false,
  series: null,
  chart:{
    series: null,
    width: 500,
    height: 100
  },
  inputs:{
    awsLogin:{
      username: { 
        label: "Username", 
        type: "select",
        placeholder: "Enter your username...",
        information: "This is your AWS Cognito username",
        readonly: true,
        value: "admin",
        options:[
          {text:"admin", value: "admin"},
          {text:"guest", value: "guest"},
        ],
      },
      password: { 
        label: "Password", 
        type: "password",
        placeholder: "Enter password here...",
        information: "Enter password here...",
        value: ""
      },
    },
    awsConfig:{
      bucket: { 
        label: "AWS S3 Bucket Name", 
        type: "text",
        placeholder: "Enter AWS S3 Bucket Name here...",
        information: "Enter AWS S3 Bucket Name here...",
        value: ""
      },
      region: { 
        label: "AWS Region", 
        type: "select",
        placeholder: "Pick your AWS region",
        information: "AWS Region Identifier. Pick us-east-1 for easy S3 bucket naming.",
        value: "us-east-1",
        options:[
          {text:"us-east-1", value: "us-east-1"},
          {text:"us-east-2", value: "us-east-2"},
          {text:"us-west-1", value: "us-west-1"},
          {text:"us-west-2", value: "us-west-2"},
        ],
      },
      userPoolId: { 
        label: "AWS User Pool Id", 
        type: "text",
        placeholder: "Enter AWS User Pool Id here...",
        information: "Enter AWS User Pool Id here...",
        value: "" //e.g us-east-1_WvkalowgA
      },
      clientId: { 
        label: "AWS User Pool Client Id", 
        type: "text",
        placeholder: "Enter AWS Client Id here...",
        information: "Enter AWS Client Id here...",
        value: "" // e.g 7i36jg8gdgooafqhf46up4v704
      },
      identityPoolId: { 
        label: "AWS Identity Pool Id", 
        type: "text",
        placeholder: "Enter AWS Identity Pool Id here...",
        information: "Enter AWS Identity Pool Id here...",
        value: "" // e.g us-east-1:94c5e4cf-d7bf-4d9c-916b-c8099e9150fe
      },    
      websocket_api: { 
        label: "Websocket API", 
        type: "text",
        placeholder: "Enter AWS User Pool Id here...",
        information: "(e.g.) wss://a36mhyc4r7.execute-api.us-east-1.amazonaws.com/prod",
        value: "" // e.g wss://a36mhyc4r7.execute-api.us-east-1.amazonaws.com/prod
      },
    },
    login:{
        username: { 
          label: "Username", 
          type: "text",
          placeholder: "Enter username1 here...",
          information: "Enter username1 here...",
          value: ""
        },
        password: { 
          label: "Password", 
          type: "password",
          placeholder: "Enter password here...",
          information: "Enter password here...",
          value: ""
        },
        auth: { 
        label: "Authentication Type", 
        type: "select",
        placeholder: "Pick your authentication type",
        information: "This information typically comes from the administrator.",
        value: "saml",
        options:[
          {text:"SAML 2.0", value: "saml"},
          {text:"Open-ID", value: "openid"},
          {text:"LDAP", value: "LDAP"},
        ],
      },
      certfile: { 
        label: "Certificate File", 
        type: "file",
        placeholder: "Pick your file here...",
        information: "This is your private key file for authentication.",
        value: ""
      },
      rootcert: { 
        label: "Root Certificate", 
        type: "textarea",
        placeholder: "Cut & paste your root certificate here...",
        information: "Your trusted root Certificate Authority.",
        value: ""
      },
    },
    socketio:{
      url: { 
        label: "URL", 
        type: "text",
        placeholder: "Enter socket.io URL.",
        information: "Enter socket.io URL here..",
        value: "http://localhost:5000"
      },
      token: { 
        label: "Token", 
        type: "password",
        placeholder: "Optional auth token...",
        information: "Optional authentication token",
        value: ""
      },
      connect: { 
        label: "Auto-connect", 
        type: "select",
        placeholder: "Pick your authentication type",
        information: "This information typically comes from the administrator.",
        value: false,
        options:[
          {text:"Yes", value: true},
          {text:"No", value: false},
        ],
      },
    },    
    awsUpload:{
      file: { 
        label: "Upload", 
        type: "file",
        placeholder: "Upload",
        information: "Pick the file that needs to be uploaded!",
        value: ""
      },      
    },
    // awsSettings:{
    //   username: { 
    //     label: "Username", 
    //     type: "text",
    //     placeholder: "Enter username1 here...",
    //     information: "Enter username1 here...",
    //     value: "admin"
    //   },
    //   password: { 
    //     label: "Password", 
    //     type: "password",
    //     placeholder: "Enter password here...",
    //     information: "Enter password here...",
    //     value: "Admin123#"
    //   },
    //   s3BucketName: { 
    //     label: "AWS S3 Bucket Name", 
    //     type: "text",
    //     placeholder: "Enter AWS S3 Bucket Name here...",
    //     information: "Enter AWS S3 Bucket Name here...",
    //     value: ""
    //   },
    //   websocket_api: { 
    //     label: "Websocket API", 
    //     type: "text",
    //     placeholder: "Enter AWS User Pool Id here...",
    //     information: "(e.g.) wss://a36mhyc4r7.execute-api.us-east-1.amazonaws.com/prod",
    //     value: ""
    //   },
    //   userPoolId: { 
    //     label: "AWS User Pool Id", 
    //     type: "text",
    //     placeholder: "Enter AWS User Pool Id here...",
    //     information: "Enter AWS User Pool Id here...",
    //     value: ""
    //   },
    //   clientId: { 
    //     label: "AWS User Pool Client Id", 
    //     type: "text",
    //     placeholder: "Enter AWS Client Id here...",
    //     information: "Enter AWS Client Id here...",
    //     value: ""
    //   },
    //   identityPoolId: { 
    //     label: "AWS Identity Pool Id", 
    //     type: "text",
    //     placeholder: "Enter AWS Identity Pool Id here...",
    //     information: "Enter AWS Identity Pool Id here...",
    //     value: ""
    //   },    
    //   region: { 
    //     label: "AWS Region", 
    //     type: "select",
    //     placeholder: "Pick your AWS region",
    //     information: "AWS Region Identifier. Pick us-east-1 for easy S3 bucket naming.",
    //     value: "us-east-1",
    //     options:[
    //       {text:"us-east-1", value: "us-east-1"},
    //       {text:"us-east-2", value: "us-east-2"},
    //       {text:"us-west-1", value: "us-west-1"},
    //       {text:"us-west-2", value: "us-west-2"},
    //     ],
    //   },
    //   idToken: { 
    //     label: "AWS Id Token", 
    //     type: "textarea",
    //     placeholder: "AWS Id Token...",
    //     information: "Id Token generated by successful Cognito User Pool login",
    //     value: ""
    //   },
    //   account: { 
    //     label: "AWS Account Number", 
    //     type: "text",
    //     placeholder: "AWS Account Number",
    //     information: "AWS Account Numbera associated with the provided login",
    //     value: ""
    //   },
    //   userid: { 
    //     label: "AWS Account userid", 
    //     type: "text",
    //     placeholder: "AWS Account userid",
    //     information: "AWS Account userid associated with the provided login",
    //     value: ""
    //   },
    //   arn: { 
    //     label: "AWS Resource Name", 
    //     type: "text",
    //     placeholder: "AWS Resource Name",
    //     information: "AWS Resource Name associated with the provided login",
    //     value: ""
    //   },
    //   accessKeyId: { 
    //     label: "AWS Access Key Id", 
    //     type: "text",
    //     placeholder: "AWS Access Key Id",
    //     information: "AWS Access Key Id",
    //     value: ""
    //   },
    //   secretAccessKey: { 
    //     label: "AWS Secret Access Key", 
    //     type: "text",
    //     placeholder: "AWS Secret Access Key",
    //     information: "AWS Secret Access Key",
    //     value: ""
    //   },
    // },
  }
})

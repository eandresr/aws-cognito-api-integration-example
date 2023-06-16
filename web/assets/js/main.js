// Global vars and consts
const maindomain = "example.com";

// AWS API Gateway vars for JWT Validation
const apiversion = "v0";
const apigateway = `www1.${maindomain}/${apiversion}`;
const checkAPIwithAuthenticationURL = `https://www1.${maindomain}/${apiversion}/auth-validation`; // This is just an example context, could be different

// AWS Cognito vars as we need to build the URL with some parameters, and as we will need only the JWT for the authentication, the main part would be "&response_type=token&scope=aws.cognito.signin.user.admin&redirect_uri="
const cognito = "example.auth.eu-west-1.amazoncognito.com";
const callback = "https://www1." + maindomain + "/index.html"; // example
const clientid = "example123"; // example
const logincognitoURL = "https://" + cognito + "/login?client_id=" + clientid + "&response_type=token&scope=api%2Fget+aws.cognito.signin.user.admin&redirect_uri=" + callback;

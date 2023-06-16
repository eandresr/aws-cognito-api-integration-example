# aws-cognito-api-integration-example

Simple repo aiming to explain with examples how to connect Front-End JS+HTML web and AWS API Gateway using Cognito as IDP

The content of the web shoul be uploaded into an S3 bucket where our domain www.exampleweb.com should point, the cognito Domain will be auth.exampleweb.com and finally the API will reside under api.exampleweb.com. This way we will solve the CORS problems.
// Global Helpers
// Messaging
function show_message(message){
  // We will show the error message
  var big_box = document.createElement('div');
  big_box.id = 'big_box';
  big_box.style = 'position: absolute; top:25%;background-color:white; width:50%; left:25%; padding-top:0em; padding-bottom:3em; padding-left:1em; padding-right:1em; height: 19em;text-align: center';
  var big_box_text = document.createElement('p');
  big_box_text.innerHTML = message;
  big_box.appendChild(big_box_text);
  var big_box_closebtn = document.createElement('button');
  big_box_closebtn.innerHTML = "CLOSE";
  big_box_closebtn.setAttribute("onclick", "document.body.removeChild(document.getElementById('big_box'));");
  big_box.appendChild(big_box_closebtn);
  document.body.appendChild(big_box);
}

// Cookies helpers
function getCookie(cname) {
    let name = cname + "=";
    let decodedCookie = decodeURIComponent(document.cookie);
    let ca = decodedCookie.split(';');
    for(let i = 0; i <ca.length; i++) {
      let c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
      }
    }
    return "";
}

function setCookie(name, value) {
    const expiration = new Date();
    expiration.setTime(expiration.getTime() + (30 * 60 * 1000));
    let expires = "expires="+expiration.toUTCString();
    document.cookie = name + "=" + value + ";" + expires + ";path=/";
}

// AWS Helpers
// Session Token checker
async function apiGatewayAuthenticationCheck(token){
  try {
    const response = await fetch(checkAPIwithAuthenticationURL, {
      headers: {Authentication: "Bearer " + token}
    })
    if (response?.ok) {
      console.log("Backend API Status is True so the provided token is as expected");
      setCookie("access_token", token);
      show_message("Backend API Status is True so the provided token is as expected");
      window.location.href = "/index.html";
    } else {
      console.log(`Backend API Status failed, HTTP Response Code: ${response.json}`)
      if (response.status >= 400 && response.status <= 403){
        setCookie("access_token", "");
        window.alert("The session token was expired, yo have to login again");
        window.location.href = "/index.html";
      }
    }
  }
  catch (error) {
    console.error("Backend API Status failed" + error);
  }
}

function apiGatewayAuthenticationCheck_oldstyle(token){
  sess_xhttp.open("GET", checkAPIwithAuthenticationURL, true);
  sess_xhttp.setRequestHeader("Authentication", "Bearer " + token);
  sess_xhttp.onload = function() {
    if (Number(this.status) <= 204){
      console.log("Backend API Status is True so the provided token is as expected");
      return true;
    }
    else{
      console.log("Backend API Status failed");
      return false;
    }	
  }
    sess_xhttp.send();
}

// Requests
// GET
// As get usually requires multiple calls, async is not my option
function aws_standard_get_request(url){
  try{
    const xhttp = new XMLHttpRequest();
    xhttp.onload = function() {
      if (this.status <= 204){
        console.log("GET Request was Done");
        return JSON.parse(this.responseText);
      }else{
        alert("Problems trying to make the GET request.");
        return false;
      }
    }
    //Send the proper header information along with the request
    xhttp.setRequestHeader('Content-type', 'application/json;charset=UTF-8');
    xhttp.setRequestHeader("Authentication", "Bearer " + getCookie("access_token"));
    xhttp.open("GET", url);
    xhttp.send();
  }
	catch (error){
    alert("Problems trying to make the GET request. Error: " + error);
  }
}

// POST
async function aws_standard_json_post_request(url, payload, returnurl){
  try {
    const response = await fetch(url, {
      headers: {Authentication: "Bearer " + token, "Content-Type": "application/json"},
      method: "POST",
      redirect: "follow",
      body: JSON.stringify(payload)
    })
    var json = await response.json();
    if (response?.ok) {
      console.log("Data was sent to the Backend API correctly");
      window.location.href = returnurl;
    } else {
      console.log(`Backend API Status failed, HTTP Response Code: ${response}`)
      if (response.status >= 400 && response.status <= 403){
        setCookie("access_token", "");
        console.log(response);
        window.alert("The session token was expired, yo have to login again");
        window.location.href = "/index.html";
      }
      show_message(`Backend failed, HTTP Response Code: ${response?.status}`);
    }
  }
  catch (error) {
    console.error("Backend API Status failed" + error);
    show_message("Backend API Status failed" + error);
  }
}

function aws_standard_json_post_request_oldstyle(url, payload){
	const xhttp = new XMLHttpRequest();
	xhttp.onload = function() {
		if (this.status <= 204){
			console.log("POST Request was Done");
		}else{
			alert("Problems trying to make the POST request.");
		}
	 }
	 //Send the proper header information along with the request
	xhttp.setRequestHeader('Content-type', 'application/json;charset=UTF-8');
  xhttp.setRequestHeader("Authentication", "Bearer " + getCookie("access_token"));
	xhttp.open("POST", url);
	xhttp.send(JSON.stringify(payload));
}

// UPLOAD FILE
async function aws_standard_upload_request(url, fileDomId, returnurl){
  try {
    let formData = new FormData();
    let file = document.getElementById(fileDomId).files[0];
    formData.append("file", file);

    const response = await fetch(url, {
      headers: {Authentication: "Bearer " + token, "Content-Type": "multipart/form-data"},
      method: "POST",
      redirect: "follow",
      body: formData
    })
    var json = await response.json();
    if (response?.ok) {
      console.log("Data was sent to the Backend API correctly");
      window.location.href = returnurl;
    } else {
      console.log("Backend API Status failed, HTTP Response Code: ${response?.status}")
      if (response.status >= 400 && response.status <= 403){
        setCookie("access_token", "");
        window.alert("The session token was expired, yo have to login again");
        window.location.href = "/index.html";
      }
      show_message("Backend failed, HTTP Response Code: ${response?.status}");
    }
  }
  catch (error) {
    console.error("Backend API Status failed" + error);
    show_message("Backend API Status failed" + error);
  }
}

function aws_standard_upload_request_oldstyle(url, fileDomId){
  let formData = new FormData();
  let file = document.getElementById(fileDomId).files[0];
  formData.append("file", file);
	const xhttp = new XMLHttpRequest();
	xhttp.onload = function() {
		if (this.status <= 204){
			console.log("POST Request was Done");
		}else{
			alert("Problems trying to make the POST request.");
		}
	 }
	 //Send the proper header information along with the request
	xhttp.setRequestHeader('Content-type', 'multipart/form-data');
  xhttp.setRequestHeader("Authentication", "Bearer " + getCookie("access_token"));
	xhttp.open("POST", url);
	xhttp.send(formData);
}

// Session Helpers
// First of all we will check the URL looking for a access_token candidate
document.addEventListener("DOMContentLoaded", function(event) {
  console.log("Cognito URL: " + logincognitoURL);
    document.getElementById("loginLink").setAttribute("href", logincognitoURL);
  let url = window.location.href;
  if (url.indexOf("access_token") >= 0){
      var urlParams = url.split("#")[1].split("&");
      for (i=0;i<=urlParams.length; i++){
          var param = String(urlParams[i]).split("=");
          if (param[0].indexOf("access_token") >= 0){
              var access_token = param[1];
              if (apiGatewayAuthenticationCheck(access_token) == true){
                  setCookie("access_token", access_token);
                  window.location.href = "/index.html";
              }
          }
      }
  }
  //Now we will check if is there any cookie for the access_token and if it is, we will validate it
  var access_token_cookie = getCookie("access_token");
  if(access_token_cookie != ""){
      if (apiGatewayAuthenticationCheck(access_token_cookie) != true){
          setCookie("access_token", "");
          window.alert("The session token was expired, yo have to login again");
          window.location.href = "/index.html";
      }
  }
});
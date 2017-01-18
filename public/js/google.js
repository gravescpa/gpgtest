// function logout()not using
//     {
//         gapi.auth.signOut();
//         location.reload();
//     }
//     function login() 
//     {
//       var myParams = {
//         'clientid' : '936189177731-eutu5lrs35ta1e3gak6kumlokknsekqu.apps.googleusercontent.com',
//         'cookiepolicy' : 'single_host_origin',
//         'callback' : 'loginCallback',
//         'approvalprompt':'force',
//         'scope' : 'https://www.googleapis.com/auth/plus.login https://www.googleapis.com/auth/plus.profile.emails.read https://www.googleapis.com/auth/plus.me'
//       };
//       gapi.auth.signIn(myParams);
//     }

//     function loginCallback(result)
//     {
//         if(result['status']['signed_in'])
//         {
//             var request = gapi.client.plus.people.get(
//             {
//                 'userId': 'me'
//             });
            
//             request.execute(function (resp)
//             {
//                 var email = '';
//                 if(resp['emails'])
//                 {
//                     for(i = 0; i < resp['emails'].length; i++)
//                     {
//                         if(resp['emails'][i]['type'] == 'account')
//                         {
//                             email = resp['emails'][i]['value'];
                            
//                         }
//                     }
//                 }

//                 var str = "Name:" + resp['displayName'] + "<br>";
//                 // str += "Image:" + resp['image']['url'] + "<br>";
//                 // str += "<img src='" + resp['image']['url'] + "' /><br>";

//                 str += "URL:" + resp['url'] + "<br>";
//                 str += "Email:" + email + "<br>";


//                 var name = resp['displayName'];
//                 var email = resp['emails'][0]['value'];
//                 // console.log(resp);
//                 // console.log('name' + name);
//                 // console.log('email' + email);
//                 $('input[name="gname"]').attr("value", name);
//                 $('input[name="gemail"]').attr("value", email);   
//                 $("#google_login").submit(); 
//             }); 
//         }
//     }
    
//     function onLoadCallback()
//     {
//         gapi.client.setApiKey('AIzaSyBnmYVOyYzXkp44dIvpRsUjrFKO0kny9r4');
//         gapi.client.load('plus', 'v1',function(){});
//     }




//   (function() {
//    var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
//    po.src = 'https://apis.google.com/js/client.js?onload=onLoadCallback';
//    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
//  })();
//         <html lang="en">
//   <head>
//     <meta name="google-signin-scope" content="profile email">
//     <meta name="google-signin-client_id" content="936189177731-eutu5lrs35ta1e3gak6kumlokknsekqu.apps.googleusercontent.com">
//     <script src="https://apis.google.com/js/platform.js" async defer></script>
//   </head>
//   <body>
//     <div class="g-signin2" data-onsuccess="onSignIn" data-theme="dark"></div>
//     <script>
//       function onSignIn(googleUser) {
//         // Useful data for your client-side scripts:
//         var profile = googleUser.getBasicProfile();
//         console.log("ID: " + profile.getId()); // Don't send this directly to your server!
//         console.log('Full Name: ' + profile.getName());
//         console.log('Given Name: ' + profile.getGivenName());
//         console.log('Family Name: ' + profile.getFamilyName());
//         console.log("Image URL: " + profile.getImageUrl());
//         console.log("Email: " + profile.getEmail());

//         // The ID token you need to pass to your backend:
//         var id_token = googleUser.getAuthResponse().id_token;
//         console.log("ID Token: " + id_token);
//       };
//     </script>
//   </body>
// </html>
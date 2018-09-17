<?php
/**
 * Created by PhpStorm.
 * User: BikoP
 * Date: 26/07/2018
 * Time: 15:30
 */

// this file sends a very basic confirmation email to the new user via PHP's basic email service.

function sendEmail($name, $email)
{


    $subject = "Welcome aboard!";

    $message = "
<html>
<head>
<link href=\"https://fonts.googleapis.com/css?family=Barlow+Semi+Condensed:100\" rel=\"stylesheet\">
<title> Welcome aboard!</title>
<meta charset='UTF-8'>
<style>
   body {
      font-family: 'Barlow Semi Condensed', sans-serif;
      text-align: center;
   }
   .button {
      border: 3px solid black; 
      color: #FF8D02; 
      padding: 15px 48px; 
      text-align: center;
      text-decoration: none; 
      display: inline-block; 
      font-size: 16px; 
   }
    input[type=\"button\"], input[type=\"submit\"] {
                border: 1px solid black; 
                border-radius: 18px; 
                height: 40px; 
                box-sizing: border-box; 
                padding: 16px 32px; 
                color: #FF8D02; 

                
            }
</style>
</head>
<body>
   <font size=\"6\">Thank you '$name' for joining the goCab community. We hope to make 21st century transportation more efficient and inclusive. To activate your account please click on the 
   button below.
   </font>
    <input type=\"button\">
   
</body>
</html>
";

// always set content-type when sending HTML email
    $headers = "MIME-Version: 1.0" . "\r\n";
    $headers .= "Content-type:text/html;charset=UTF-8" . "\r\n";

// more headers
    $headers .= 'From: <customer@gocab.app>' . "\r\n";

    mail($email, $subject, $message, $headers);
    echo('Mail sent!');
}
?>


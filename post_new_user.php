<?php
/**
 * Created by PhpStorm.
 * User: BikoP
 * Date: 18/06/2018
 * Time: 23:50
 */

// This file reads input about a new user and uploads it to the SQL database.

require_once 'conf_email.php';
require_once 'get_id.php';
$response = array();

$servername = "localhost";
$username = "sakrtt7d_pougala";
$password = "Tarabiscotta1";
$dbname = "goCab2";

// create connection
$conn = new mysqli($servername, $username, $password, $dbname);
$db = mysqli_connect($servername, $username, $password, $dbname);


// check connection
if ($conn->connect_error) {
    die("Failed to connect to MySQL: " . $conn->connect_error);

}


if ($_SERVER['REQUEST_METHOD'] == 'POST') {

    // getting values

    $secret = $_POST['secretWord'];

    if ($secret != 'M,5Z$Tjj3y57bL)$4') exit;

    $foreName = $_POST['forename'];
    $surName = $_POST['surname'];
    $email_address = $_POST['email'];
    $pass = $_POST['password'];
    //$mobilePhone = $_POST['mobile'];
    $affiliateCode = generateRandomString();
    $bool_email = $_POST['isEmailVerified'];
    $bool_phone = $_POST['isPhoneVerified'];

    $accountPassword = hash('sha256',$pass);

    $checkUser = "SELECT * FROM account_france WHERE email = '$email_address'";
    $prevent = mysqli_query($db, $checkUser);
    $row_count = $prevent->num_rows;
    if ($row_count >= 1) {
        echo "User already exists";
    } else {

        $sql = "INSERT INTO user_account (forename, surname, email, password, affiliate_code, isPhoneVerified, isEmailVerified) VALUES ('$foreName',
    '$surName', '$email_address', '$accountPassword', '$affiliateCode', '$bool_phone', '$bool_email')";

        // $sql = "INSERT INTO account_france (forename, surname, email, password, mobile) VALUES ('John', 'Legend', 'johnlegend@gmail.com', 'superman987', '+33653636273')";

        if ($conn->query($sql) == TRUE) {
            $response["error"] = false;
            $response["message"] = "User created successfully";
            sendEmail($foreName, $email_address);

           //  create a cookie to identify the user
            $cookie_value = getID($email_address);
            echo $cookie_value;
            setcookie("user", $cookie_value);
        } else {
            $response["error"] = true;
            $response["message"] = "Error: " . $sql . "<br>" . $conn->error;
        }

        echo $response;

    }


}

echo json_encode($response);

function generateRandomString($length = 6) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyz';
    $charactersLength = strlen($characters);
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomString;
}

$conn->close();

?>
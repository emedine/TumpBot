<?php

require "twitteroauth/autoload.php";

use Abraham\TwitterOAuth\TwitterOAuth;


/*
Consumer Key (API Key)	clPEodtUWLph0ra4AdkTUf8y9
Consumer Secret (API Secret)	JtDA3P7HvYfLrPF13g1BacqcpUDLXrHuJIfgVxF6ESddRrn8w5
*/


/* basic
$connection = new TwitterOAuth(CONSUMER_KEY, CONSUMER_SECRET, $access_token, $access_token_secret);
$content = $connection->get("account/verify_credentials");
*/

function getAuth(){


}
function postImage(){
	$consumer_key = 'clPEodtUWLph0ra4AdkTUf8y9';
	$consumer_secret = 'JtDA3P7HvYfLrPF13g1BacqcpUDLXrHuJIfgVxF6ESddRrn8w5';
	$access_token = '258118580-hNAcUBdHboDmo1n01iAv6ufM55gpgA1XO1gv8jb4';
	$access_token_secret = 'pYx64jjZye6iRsYt3qNMQhhCunCe0UpARxBvwYJBLhPzW';

	$connection = new TwitterOAuth($consumer_key, $consumer_secret, $access_token, $access_token_secret);
	$content = $connection->get("account/verify_credentials");
	
	$result = $connection->upload('media/upload', array('media' => 'preview_image.png'));

	$mediaID = $result->media_id;
	$parameters = array('status' => 'First tweet','media_ids' => $mediaID);
	$response = $connection->post('statuses/update', $parameters);

	
}
postImage();
echo("hello world");


?>
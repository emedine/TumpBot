<?php
/*
!IMPORTANT! Change all instances of $_REQUEST to $_REQUEST and uncomment 'die()' on line 7 below when ready to launch.

*/

if($_SERVER['REQUEST_METHOD'] != "POST" || !$_REQUEST['functionType']){
	die();
}

/* 
require 'aws/aws-autoloader.php';
use Aws\S3\S3Client;
*/

require "twitteroauth/autoload.php";
require "AnimGif/GifCreator/AnimGif.php";

use Abraham\TwitterOAuth\TwitterOAuth;


//// FUNCTIONS


$function = $_REQUEST['functionType'];

switch($function) {

	case "saveImage":
		saveImageToServer();
		break;

	case "createGif":
		createGifToServer();
		break;


	case "imageToTwitter":
		sendImageToTwitter();
		break;
		
	case "clearUploads":
		emptyUploads();
		break;

	case "imageToAWS":
		sendDataToAWS();
		break;
	
	
}
///////////////////////////////////////////////////
/// SAVE IMAGE FUNCTIONS /////////////////
///////////////////////////////////////////////////

////// SAVE IMAGE DIRECTLY TO SERVER /////////
function saveImageToServer(){
	define('UPLOAD_DIR', '../uploads/');
	$img = $_POST['imgBase64'];
	$img = str_replace('data:image/png;base64,', '', $img);
	$img = str_replace(' ', '+', $img);
	$data = base64_decode($img);
	$fname = $_POST['fileName'];
	$file = UPLOAD_DIR.$fname.'.png';
	$success = file_put_contents($file, $data);
	console.log($success);
	print $success ? $file : 'Unable to save the file.';
}

/////// CREATE GIFS FROM ALL IMAGES
function createGifToServer(){

		$thedir = $_REQUEST["foldername"]; /// place to save the gif
		$filename = $_REQUEST["filename"];  /// gif name
		$srcnamearray = $_REQUEST["srcnames"]; /// array of image frames
		// Example for creating a slideshow from images in the "./img/" dir.
		$anim = new GifCreator\AnimGif();

		/*
		$frames = array(
		    "img/1.png","img/2.png","img/3.png",
		);
		*/
		$frames = $srcnamearray;
		// load images from a dir (sorted, skipping .files):
		// $frames = $thedir;

		// Optionally: set different durations (in 1/100s units) for each frame
		$durations = array(10);

		// Load all images from "./img/", in ascending order,
		// apply the given delays, and save the result...

		// Or: using the default 100ms even delay:
		//$anim->create($frames);

		// Or: loop 5 times, then stop:
		//$anim->create($frames, $durations, 5); // default: infinite looping

		$anim->create($frames, $durations, 1);

		/*
		$anim	-> create("img/", array(300, 500)) // first 3s, then 5s for all the others
			-> save("anim.gif");
			*/
		$anim->save($thedir."/".$filename.".gif");


}

////// POST IMAGE TO TWITTER
function sendImageToTwitter(){
	/* trumpbot v2
	$consumer_key = '6XyFQtyjc7HM7yPEvcJwofKEG';
	$consumer_secret = 'ut0AjeYJSSwhemGQr8l4ZKTmpYavVV1qEUHLwqFLZ2NO7m89Oo';
	$access_token = '828372954517942272-G4II7EQUFaII9AGxcJwL0fBLwKc93SQ';
	$access_token_secret = 'bUVTco45s3S2YRyyijppejo1u2BggFuP54nD3Lhkd6Mmf';
	*/


	///* trumpbot v3
	$consumer_key = 'i7ITWpGLzOUkC81tq8uzqjpbX';
	$consumer_secret = 'H5ngKhRTAVDaACCDhmGUpWSMoFvxTi0uOZUeL3nDE56PF2jMeX';
	$access_token = '828372954517942272-CDXnezqiXfEdwBt97s2ZONtjQ1Po0nM';
	$access_token_secret = 'yZxoH2kl5EQBIoljq6UAu5yrMwviXZLeQrF5W2vWkypNn';
	//*/

	// data from AJAX
    $imgCaption = $_REQUEST["imageCaption"];
    $imgPath = $_REQUEST["imagePath"]; ///"gqSWZXRhzE.gif"; // 

	$connection = new TwitterOAuth($consumer_key, $consumer_secret, $access_token, $access_token_secret);
	//// $connection = new TwitterOAuth(CONSUMER_KEY, CONSUMER_SECRET, $access_token, $access_token_secret);
	$connection->setTimeouts(25, 30);  /// connection time, total time
	$content = $connection->get("account/verify_credentials");
	/*
	$media1 = $connection->upload('media/upload', ['media' => $_REQUEST['imageData']]);
	$mediaID = $media1->media_id;
	$parameters = array('status' => $imgCaption,'media_ids' => $mediaID);
		
	$response = $connection->post('statuses/update', $parameters);
	*/
	echo($imgCaption + " " + $imgPath);
	/* upload image works*/
	$result = $connection->upload('media/upload', array('media' => '../uploads/'.$imgPath));
	/* now that the image is uploaded, post it */
	$mediaID = $result->media_id;
	/* text, media */
	$parameters = array('status' => $imgCaption,'media_ids' => $mediaID);
	$response = $connection->post('statuses/update', $parameters);
}

function emptyUploads(){

	 /// now that we've posted, let's kill all files
    $dir = "../uploads";
    $di = new RecursiveDirectoryIterator($dir, FilesystemIterator::SKIP_DOTS);
    $ri = new RecursiveIteratorIterator($di, RecursiveIteratorIterator::CHILD_FIRST);
    foreach ( $ri as $file ) {
        $file->isDir() ?  rmdir($file) : unlink($file);
    }
    return true;
}

///// send RAW IMAGE DATA to AMAZON ////////
function sendDataToAWS(){

	global $awsAccessKeyId;
	global $awsSecretAccessKey;
	global $awsBucket;
	global $awsFolder;

	// instantiate s3 client
	$s3 = S3Client::factory(array(
		"key"    => $awsAccessKeyId, 
		"secret" => $awsSecretAccessKey,
	));
	
	// get cover toggle
	$isPhoto= $_REQUEST["isPhotoCollage"];
	
	//parse object body
	$imageData = $_REQUEST["imageData"];
	$imageData = str_replace(" ", "+", $imageData);
	$imageData = base64_decode($imageData);	
	
	//put object
	try {
		$s3result = $s3 -> putObject(array(
			"Bucket" 		=> $awsBucket, 
			"Key" 			=> $awsFolder . uniqid() . ".png", 
			"ACL"   		=> "public-read", 
			"Body" 			=> $imageData,
		));
	
		//log image in mysql
		//TBD

		/// if it's a collage, send to fb
		/// otherwise, return data for montage
		if($isPhoto == "photoCollage"){
			//then post to facebook
			$facebookConfig = array();
			$facebookConfig["appId"] = FB_APP_ID;
			$facebookConfig["secret"] = FB_APP_SECRET;
			$facebookConfig["fileUpload"] = true;
			$facebook = new Facebook($facebookConfig);
			$facebookPost = array();
			$facebookPost["name"] = "I just photobombed the cast of New Girl Season 2.  Try a photobomb of your own at www.newgirlphotobomb.com.";
			$facebookPost["url"] = $s3result["ObjectURL"];
			$facebookResponse = $facebook->api("/me/photos", "post", $facebookPost);
			
		}

		//return the original image URL
		echo(json_encode(array("url" => $s3result["ObjectURL"])));

	} catch (S3Exception $e) {
		echo "There was an error uploading the file.\n".$e;
	}

}



////////// MISC UTILS ////////////



///// sanitize inputs
function check_input($value)
{

	if (get_magic_quotes_gpc())
	{
		$value = stripslashes($value);
	}
	$value = mysql_real_escape_string($value);
	$invalid_characters = array("$", "%", "#", "<", ">", "|");
	$value = str_replace($invalid_characters, "", $value);

	return $value;
}




?>
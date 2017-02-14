<?php
    # we are a PNG image
    header('Content-type: image/png');
    
    /// sanitize name
    $sanitizedname = check_input( $_POST['name'] );
     
    # we are an attachment (eg download), and we have a name
    header('Content-Disposition: attachment; filename="' . $sanitizedname .'"');
     
    #capture, sanitize, replace any spaces w/ plusses, and decode
    $encoded = $_POST['imgdata'];
    $encoded = str_replace(' ', '+', $encoded);
    $encoded = check_input($encoded);
    $decoded = base64_decode($encoded);
     
    #write decoded data
    ob_clean();
    echo $decoded;
    
    
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


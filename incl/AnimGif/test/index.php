<?php
// Example for creating a slideshow from images in the "./img/" dir.

require "../src/GifCreator/AnimGif.php";

$anim = new GifCreator\AnimGif();

// Use an array containing file paths, resource vars (initialized with imagecreatefromXXX), 
// image URLs or binary image data.
/*
$frames = array(
    imagecreatefrompng("img/pic1.png"),      // resource var
    "/../images/pic2.png",                          // image file path
    file_get_contents("/../images/pic3.jpg"),       // image binary data
    "http://thisisafakedomain.com/images/pic4.jpg", // URL
);
*/
$frames = array(
    "img/1.png","img/2.png","img/3.png",
);


// Or: load images from a dir (sorted, skipping .files):
//$frames = "../images";

// Optionally: set different durations (in 1/100s units) for each frame
$durations = array(300);

// Load all images from "./img/", in ascending order,
// apply the given delays, and save the result...

$anim->create($frames, $durations);

/*
$anim	-> create("img/", array(300, 500)) // first 3s, then 5s for all the others
	-> save("anim.gif");
	*/
$anim->save("animated.gif");
?>

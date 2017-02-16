<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:fb="http://ogp.me/ns/fb#">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="keywords" content="Trump Bot, Nasty Women, Eric Medine, Twitter API Fetcher" />
  
    <meta name="author" content="Trump Bot" />
    <meta property="og:image" content="http://ericmedine.com/TrumpBot/images/preview_image.png" />
    <title>Trumpbot</title>
    <link href="css/style.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="js/jquery.1.6.1.min.js"></script>
    <script src="js/processing.min.js"></script>
    <!-- <script type="text/javascript" src="js/canvassaver.js"></script> -->
    <script type="text/javascript">

       


    ///// COMMUNICATE WITH PROCESSING
    var procElem;
     
    var frameIndex = 0; /// this gets reset every time we do a tweet
    var tweetCaption = ""; 

    function startSketch() {
       switchSketchState(true);
    }

    function stopSketch() {
       switchSketchState(false);
    }

    function switchSketchState(on) {
       if (!procElem) {
           procElem = Processing.getInstanceById('sketch');
           console.log("THERE IS PROCESSING");
       }

       
    }

    ///////////// for lip synching animation ///////////////
    function sendTextToSketch(t){
      try{
         
         var tString = t.replace(/<(?:.|\n)*?>/gm, '');
         
          console.log("send: " + tString);
          procElem = Processing.getInstanceById('sketch');
          procElem.addText(tString);
          if (!procElem) {
             
             console.log("error finding processing element");
           }

      } catch(e){

        console.log("error sending text");
      }
     

    }

    /// tweets
    function sendTweetToSketch(t, n, u){
      var tString = "";
      var uString = "";
      try{

         tString = t.replace(/<(?:.|\n)*?>/gm, '');
         uString = u.replace(/<(?:.|\n)*?>/gm, '');
         uString = uString.replace(/\s+/g, ' ').trim();
         uString = uString.replace(/\n/g," ");
         /// get rid of the username and keep the @name
         uString = uString.substring(uString.indexOf("@") + 1);
         uString = "@" + uString;
         /// var dString = d.replace(/<(?:.|\n)*?>/gm, '');
        /// WE SHOULD SEND THE USER NAME ALSO /////
        if(uString === "@saysrealtrump"){

          /// makes sure not replying to myself
        } else {

          procElem = Processing.getInstanceById('sketch');
          procElem.addTweet(tString, "RT " + uString + " says ");
          console.log("from: " + uString + " says: " + tString);
          if (!procElem) {
             
             console.log("error finding processing element");
           }

        }
        

      } catch(e){

        console.log("error sending tweet: " + e);
      }
    }

    /////////// LISTEN TO PROCESSING /////////////////////////////
    function reDoSearch(){

      console.log("I hear you");
    }


    /// save single frame from Processing
    function saveCurFrame(findex, tweet){
      frameIndex = findex;
      tweetCaption = tweet;
      createCollage();
    }

    function saveGifFromFrames(tweet){
      console.log("save gif");
      tweetCaption = tweet;
      createGif("../uploads", randomString(10, "a")); ///// pass it the correct folder name
    }


    function randomString(len, an){
      an = an&&an.toLowerCase();
      var str="", i=0, min=an=="a"?10:0, max=an=="n"?10:62;
      for(;i++<len;){
        var r = Math.random()*(max-min)+min <<0;
        str += String.fromCharCode(r+=r>9?r<36?55:61:48);
      }
      return str;
    }


    var bound = false;

    function bindJavascript() {
      var pjs = Processing.getInstanceById('sketch');
      if(pjs!=null) {
          pjs.bindJavascript(this);
       bound = true;
      }
      if(!bound) setTimeout(bindJavascript, 250);
    }

    bindJavascript();

</script>
</head>
<body>

<!-- 
  <a href="#" id="SaveGif" >SaveGif</a>
  <br><br>
-->

<div id="content-main" align="center">
    <canvas id="sketch" data-processing-sources="main/main.pde" width="400" height="300"></canvas>
 
</div>
<br><br>
<div id="content-buffer">
     <canvas id="buffercanvas" width="400" height="300"></canvas>
</div>
<!-- extra canvas for drawing -->
 
    <!-- 
    <a href="#" id="nav">Load tweets @shitTrumpSays</a>
    <a href="#" id="startText">Speak!</a>
  -->

    <div id="example4"></div>

    <!-- this hidden form uploads the image to the server -->

    <!--
    <input type="text" id="textEntry" name="textEntry" value="I have tiny hands"/><br>
  -->
 
    <script type="text/javascript" src="js/twitterFetcher.js"></script>
    <script type="text/javascript" src="js/twitterConsole.js"></script>
     <!-- <script type="text/javascript" src="js/imageHandling.js"></script> -->
    <script>
   

    var tweetCaption = ""; /// default tweet caption

    
     $( "#SaveGif" ).click(function() {

        console.log("save gif");
        /// createGif("../uploads", randomString(10, "a")); ///// pass it the correct file name
        saveGifFromFrames("CLICK TO SAVE");
        // saveFrameCollage();
      });



  ////////////////////////////////////////////
  //////////// SAVE IMAGE TO SERVER ////////
  ///////////////////////////////////////////

  function createCollage(){
    
      // console.log("SAVE IMAGE");
      var src = document.getElementById('sketch');
      var ctxsrc = src.getContext('2d');


      var can1 = document.createElement('canvas');
      can1.setAttribute('width', '400')
      can1.setAttribute('height', '300');
      can1.id = "foregroundImage";
      
      var ctx1 = can1.getContext('2d');

      ctx1.drawImage(src, 0, 0 ); 

      var can2 = document.createElement('canvas');
      can2.setAttribute('width', '400')
      can2.setAttribute('height', '300');
      can2.id = "backgroundImage";
      $('#MergeCanvas').focus();
      var context2 = can2.getContext('2d');

      make_base(can1, can2);
       
      function make_base(can1, can2)
      {
        $("#MergeCanvas").attr("tabindex",-1).focus();
        base_image = new Image();
        base_image.src = "images/background_mh_contrast2.gif";
        base_image.onload = function(){
          context2.drawImage(base_image, 0, 0, 400,300); /// scale up to fit? 
          // context = can2.getContext('2d');
          var can3 = document.getElementById('buffercanvas');
          var ctx3 = can3.getContext('2d');
          
          ctx3.drawImage(can2, 0, 0);
          ctx3.drawImage(can1, 0, 0);

          saveFrameToServer();
          /// saveImageToServer();
        }
      }
  }

  ////////// SAVE FRAME TO SERVER ////////////////
    function saveFrameToServer(){


      // console.log("saving single frame to server");
      var fn = frameIndex;
      var canvas  = document.getElementById("buffercanvas");
      var dataURL = canvas.toDataURL();

      $.ajax({
        type: "POST",
         url: "incl/functions.php",
         data: {
           functionType: "saveImage",
           fileName : fn,
           imgBase64: dataURL
        },success: function (data) {
               
                /// no callback functions since we need 
                /// to wait for all frames to be saved before 
                /// creating gif and posting to twitter
            },
            error: function (textStatus, errorThrown) {
                console.log("error saving image");
            }
      });

    
  }

  function createGif(foldername, filename){
      console.log("saving gif to server");

      var foln = foldername; // folder all the frames are stored in
      var filen = filename;
      var filesArray = new Array();
      for(var i = 0; i< frameIndex; i++){

        filesArray.push("../uploads/" + i+ ".png");
      }

      console.log("files: " + filesArray.toString());
      $.ajax({
        type: "POST",
         url: "incl/functions.php",
         data: {
           functionType: "createGif",
           foldername : foln,
           filename : filen,
           srcnames : filesArray

        },success: function (data) {
                console.log("created gif");
                /// now that gif is saved, post it with the twitter data
                ////console.log("POST GIF AND TWEET TO TWITTER: " + filen + " " + tweetCaption);
                prepMemePost(filen);
            },
            error: function (textStatus, errorThrown) {
                console.log("error saving image");
            }
      });
  }


  //////////// SAVE A FINAL STATIC MEME TO SERVER ////////////////////////
  function saveImageToServer(){
     //  console.log("saving image to server");
      var fn = randomString(10, "a");
      var canvas  = document.getElementById("buffercanvas");
      var dataURL = canvas.toDataURL();

      $.ajax({
        type: "POST",
         url: "incl/functions.php",
         data: {
           functionType: "saveImage",
           fileName : fn,
           imgBase64: dataURL
        },success: function (data) {
                prepMemePost(fn);

            },
            error: function (textStatus, errorThrown) {
                console.log("error saving image");
            }
      });

    
  }
  
  /// little delay to make sure the gif has time to save
  function prepMemePost(fn){
    console.log("prep mempost for gif: " + fn);
    setTimeout(function () { 
       postMeme(fn + ".gif");
    }, 1000);
    

  }

/// little delay to make sure the gif has time to upload before nuking all files
  function prepFileDelete(fn){
    
    setTimeout(function () { 
    deleteOldGif();
    }, 5000);
    

  }


  //// POST FILENAME IMAGE TO TWITTER USING OATH  /////////////
  function postMeme(fn){
    var filePath = fn;
    console.log("sending uploaded image to twitter: " + fn);
    console.log("posting tweet to twitter: " + tweetCaption);

    ///*
     $.ajax({
             type: "POST",
             url: "incl/functions.php",
             data: {
                 functionType: "imageToTwitter",
                 imageCaption :tweetCaption,
                 imagePath :filePath

             },success: function (data) {
                console.log("successful send: " + data);
                prepFileDelete();
            },
            error: function (textStatus, errorThrown) {
                console.log("error posting tweet");
            }

          //done after here
          
        });
//*/
  }

  function deleteOldGif(){
        console.log("deleting files from uploads");
        $.ajax({
             type: "POST",
             url: "incl/functions.php",
             data: {
                 functionType: "clearUploads"
                 
                 /// fileName : theguid
             },success: function (data) {
                console.log("success empty uploads");
            },
            error: function (textStatus, errorThrown) {
                console.log("error deleting uploads");
            }

          //done after here
          
        });


  }


     </script>
  </body>

</html>

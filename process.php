<?php
/**
Runnable examples functionality

Copyright: 2012 by Digital Mars

License:   http://boost.org/LICENSE_1_0.txt, Boost License 1.0

Authors:   Andrei Alexandrescu, Damian Ziemba
*/

if (!isset($_POST))
    $_POST = $HTTP_POST_VARS;

if (!isset($_POST["code"]))
    return;

$code = $_POST['code'];
$stdin = $_POST['stdin'];
$args = $_POST['args'];

$str = "compiler=dmd2&code=$code&stdin=$stdin&args=$args&unittest=1&debug=0&disassembly=0";

$result = "";
$fp = fsockopen("dpaste.dzfl.pl", 80, $errno,$errstr, 15); 
if ($fp)
{ 
    fputs($fp, "POST /request/ HTTP/1.1\r\n"); 
    fputs($fp, "Host: dpaste.dzfl.pl\r\n"); 
    fputs($fp, "Content-type: application/x-www-form-urlencoded\r\n"); 
    fputs($fp, "Content-length: ".strlen($str)."\r\n"); 
    fputs($fp, "Connection: close\r\n\r\n"); 
    fputs($fp, $str."\r\n\r\n"); 
    while(!feof($fp)) 
        $result .= fgets($fp,4096); 
    fclose($fp); 
}
$pos = strpos($result, '<?xml ');

if ($pos !== false) {
    header("Content-Type: application/xml");
    echo substr($result, $pos, -5);
}
else
    echo $result;
?>

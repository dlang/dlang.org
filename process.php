<?php

if (!isset($_POST))
    $_POST = $HTTP_POST_VARS;

if (!isset($_POST["code"]))
    return;

$url = 'http://dpaste.dzfl.pl/request/';

$code = $_POST['code'];
$stdin = $_POST['stdin'];
$args = $_POST['args'];

echo file_get_contents($url ."?compiler=dmd&ptr=64&code={$code}&stdin=$stdin&args=$args");

?>

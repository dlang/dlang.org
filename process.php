<?php
if (!isset($_POST["code"]))
    return;

$url = 'http://dpaste.dzfl.pl/request';
$fields = array(
            'compiler'=>"dmd2",
            'ptr'=>"64",
            'code'=>$_POST['code'],
            'stdin' => $_POST['stdin'],
            'args'=>$_POST['args'],
        );
$ch = curl_init();

curl_setopt($ch,CURLOPT_URL,$url);
curl_setopt($ch,CURLOPT_POST,count($fields));
$code = ($_POST['code']);
$stdin = $_POST['stdin'];
$args = $_POST['args'];

curl_setopt($ch,CURLOPT_POSTFIELDS,"compiler=dmd&ptr=64&code={$code}&stdin=$stdin&args=$args");

$result = curl_exec($ch);

curl_close($ch);

?>

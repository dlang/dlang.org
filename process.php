<?php
if (!isset($HTTP_POST_VARS["code"]))
    return;

$url = 'http://dpaste.dzfl.pl/request';
$fields = array(
            'compiler'=>"dmd2",
            'ptr'=>"64",
            'code'=>$HTTP_POST_VARS['code'],
            'stdin' => $HTTP_POST_VARS['stdin'],
            'args'=>$HTTP_POST_VARS['args'],
        );
$ch = curl_init();

curl_setopt($ch,CURLOPT_URL,$url);
curl_setopt($ch,CURLOPT_POST,count($fields));
$code = ($HTTP_POST_VARS['code']);
$stdin = $HTTP_POST_VARS['stdin'];
$args = $HTTP_POST_VARS['args'];

curl_setopt($ch,CURLOPT_POSTFIELDS,"compiler=dmd&ptr=64&code={$code}&stdin=$stdin&args=$args");

$result = curl_exec($ch);

curl_close($ch);

?>

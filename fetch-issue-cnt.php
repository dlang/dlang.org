<html>
<p align=right>
<?php
$url = 'http://d.puremagic.com/issues/buglist.cgi?' . $_SERVER["QUERY_STRING"];
#echo $url;
$data = file_get_contents($url);
$regex = '/(\d+) issues found/';
preg_match($regex,$data,$match);
#var_dump($match);
echo $match[1];
?>
</p>
</html>

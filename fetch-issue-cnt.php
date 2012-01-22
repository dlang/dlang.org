<html>
<p align=right>
<?php

# Format is as follows:
#"Severity","Number of issues"
#"regression",32
#"blocker",16
#"critical",53
#"major",160
#"normal",1531
#"minor",101
#"trivial",17
#"enhancement",707

$url = 'http://d.puremagic.com/issues/report.cgi?' . $_SERVER["QUERY_STRING"];
$data = file_get_contents($url);
$lines = explode("\n", $data);
unset($lines[0]);

$result = 0;
foreach ($lines as $line)
{
  $kv = explode(",", $line);
  $result += $kv[1];
}

echo $result;

#$url = 'http://d.puremagic.com/issues/buglist.cgi?' . $_SERVER["QUERY_STRING"];
#echo $url;
#$data = file_get_contents($url);
#$regex = '/(\d+) issues found/';
#preg_match($regex,$data,$match);
#var_dump($match);
#echo $match[1];
?>
</p>
</html>

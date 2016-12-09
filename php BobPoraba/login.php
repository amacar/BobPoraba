<?php

const cookie = "cookies.txt";
const username = “username”;
const password = “password”;

// get cookie and hidden inputs
$content = get("https://moj.bob.si/", true);

//parse inputs and post login data
$data = array();
$data['UserName'] = username;
$data['Password'] = password;
$data['IsSamlLogin'] = 'False';
$data['InternalBackUrl'] = '';
$data['IsPopUp'] = 'True';
$data['__RequestVerificationToken'] = getHiddenInput($content, '__RequestVerificationToken');
$content = post("https://prijava.bob.si/SSO/Login/Login", $data);

//get additional hidden inputs
$content = get("https://moj.bob.si/");

//parse inputs and post additional data
$data = array();
$data['authTicket'] = getHiddenInput($content, 'authTicket');
$data['subscriberService'] = getHiddenInput($content, 'subscriberService');
$content = post("https://moj.bob.si/ssologin/login?returnUrl=/", $data);

//login successful, open whatever page you want to parse
$content = get("https://moj.bob.si/racuni-in-poraba/stevec-porabe");

//get usageCounterTable
$table = substr($content, strpos($content, '<table id="usageCounter'));
$table = substr($table, 0, strpos($table, '</table'));
echo $table;


//**Functions**

function get($url, $firstTime = false) {
	$ch = curl_init($url);
	curl_setopt($ch, CURLOPT_COOKIEJAR, cookie);
	if(!$firstTime){
		curl_setopt($ch, CURLOPT_COOKIEFILE, cookie);
	}
	curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); 
	$content = curl_exec($ch);
	curl_close($ch);
	
	return $content;
}

function post($url, $data) {
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_COOKIEJAR, cookie);
	curl_setopt($ch, CURLOPT_COOKIEFILE, cookie);
	curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); 
	curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));
	curl_setopt($ch, CURLOPT_POST, 1); 
	curl_setopt($ch, CURLOPT_URL, $url);
	$content = curl_exec($ch);
	curl_close($ch);
	
	return $content;
}

function getHiddenInput($content, $inputName) {
	$input = substr($content, strpos($content, $inputName));
	$input = substr($input, strpos($input, "value") + 7);
	$input = substr($input, 0, strpos($input, "\""));
	
	return $input;
}
?>
$.doAsyncCall = function(myvalue) { 
	$.ajax({
      		type: 'POST',
		url: 'https://tgzetny5lb.execute-api.us-west-2.amazonaws.com/prod/kv',
		crossDomain: true,
		data: JSON.stringify({ "key" : myvalue }),
		contentType:"application/json",
		dataType: 'json',

		error: function(e) {
			$('#msg').text('');
			//$('#msg').text("http request error");
			console.log(e);
      		},
		success: function(responsedata, status) {
			if (responsedata.match == "") {
				$('#msg').text("eh?");
			} else {
         			//$('#msg').text(responsedata.match);
         			$('#msg').text("");
			}
      		}
    	});
};

function readInput(value) {
	value = value.replace(/^\s+/, '').replace(/\s+$/, '');
	if (value == "") {
		$('#msg').text('');
	}
	else {
		//window.location.replace('dummy.html');
		$.doAsyncCall(value);
	}
};
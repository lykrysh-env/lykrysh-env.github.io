$.doAsyncCall = function(myvalue) { 
	$.ajax({
      		type: 'POST',
		url: 'https://0vym4r6sh7.execute-api.us-west-2.amazonaws.com/first/kv',
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
         		$('#msg').text(responsedata.match + " " + status);
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
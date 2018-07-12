$.doAsyncCall = function(myvalue) { 
	$.ajax({
		url: 'http://localhost:8080/kv',
		crossDomain: true,
		data: {
			key : myvalue,
			format: 'text'
		},
		error: function(e) {
			$('#msg').text("http request error");
			console.log(e);
      		},
		dataType: 'json',
		success: function(response) {
			if (response.notfound) {
         			$('#msg').text('not found');
			} else {
         			$('#msg').text(response.match);
			}
      		},
      		type: 'POST'
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
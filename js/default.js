$(document).ready(function() {
	$('#teambut').hover(function() {
		var curr = sessionStorage.getItem('formIsVisible');
        	if (curr == 'no') {
			$('#topform').css('right', '7rem');
			sessionStorage.setItem('formIsVisible', 'yes');

		} else {
			sessionStorage.setItem('formIsVisible', 'no');
		}
	});
	$('#teambut').click(function() {
		var curr = sessionStorage.getItem('formIsVisible');
        	if (curr == 'yes') {
			$('#topform').css('right', '-20rem');

		}
         	$('#msg').text('');
	});
});
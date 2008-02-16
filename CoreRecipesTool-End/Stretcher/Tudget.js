var stretcher;
var complete;

function restart() {
	startTest();
}

function startTest() {
	complete = false;
	document.getElementById("restart").style.display = 'none';
	var selectedTest = widget.preferenceForKey("selectedTest");
	if (!selectedTest || selectedTest.length == 0) {
		var availableTests = FortunePlugin.availableTests();
		selectedTest = availableTests[0];
	}
	FortunePlugin.setFileName(selectedTest);
	FortunePlugin.restartTests();
	getNewQuestion();
}

function keyeventhandler(event) {
	// alert("c == " + event.keyIdentifier);
	var score = null;	
	// need 00 and 0000 variants as it appears that leopard uses different ones
	if (event.keyIdentifier == "U+000031" || event.keyIdentifier == "U+0031")
		score = -1;
	if (event.keyIdentifier == "U+000032" || event.keyIdentifier == "U+0032")
		score = 0;
	if (event.keyIdentifier == "U+000033" || event.keyIdentifier == "U+0033")
		score = 1;
	if (score != null)
		next(score);
}

function getNewQuestion() {
	var line = FortunePlugin.getNewQuestion();
	if (!line) {
		line = "Test Complete";
		hideIcons();
		document.getElementById("restart").style.display = 'inline';
		animation.callback = function() { complete = true; }
	} else {
		document.getElementById("crying").style.display = 'inline';
		document.getElementById("happy").style.display = 'inline';
		document.getElementById("worried").style.display = 'inline';
	}
	document.getElementById("ctrTitle").innerHTML = line;
}

function hideIcons() {
	document.getElementById("crying").style.display = 'none';
	document.getElementById("happy").style.display = 'none';
	document.getElementById("worried").style.display = 'none';
}

function getAnswerAndScoreIt(score) {
	if (complete)
		return;
	// var url = "file://localhost/Users/lypanov/Desktop/Audio.mov";
	// document.getElementById("audio").innerHTML = "<embed src=\"" + url + "\" autostart=\"true\"></embed>";
	var line;
	hideIcons();
	if (score == -1)
		document.getElementById("crying").style.display = 'inline';
	else if (score == 1)
		document.getElementById("happy").style.display = 'inline';
	else
		document.getElementById("worried").style.display = 'inline';
	line = FortunePlugin.getAnswerAndScoreIt(score);
	document.getElementById("ctrTitle").innerHTML = line;
}

var glassDoneButton;
var whiteInfoButton;

function loaded(e) {
	startTest();
	stretcher = new Stretcher(document.getElementById('front'), 10, 100, function() {});
	stretcher.stretch(e);
	glassDoneButton = new AppleGlassButton(document.getElementById("doneButton"), "Done", hidePrefs);
	whiteInfoButton = new AppleInfoButton(document.getElementById("infoButton"), document.getElementById("front"), "white", "white", showPrefs);
}

function showPrefs() {
	var front = document.getElementById("front");
	var back = document.getElementById("back");

	if (window.widget)
		widget.prepareForTransition("ToBack");		// freezes the widget so that you can change it without the user noticing

		var selectedTest = widget.preferenceForKey("selectedTest");

		var availableTestsSelect = document.getElementById("testSelect");
		availableTestsSelect.options.length = 0;
		var availableTests = FortunePlugin.availableTests();
		for (var i = 0; i < availableTests.length; i++) {
			var path = availableTests[i];
			var basename = path.substring(path.lastIndexOf("/") + 1, path.lastIndexOf("."));
			availableTestsSelect.options[i] = new Option(basename, path);
			if (selectedTest == availableTests[i])
				availableTestsSelect.options[i].selected = true;
		}
	
	front.style.display="none";		// hide the front
	back.style.display="block";		// show the back
	
	if (window.widget)
		setTimeout ('widget.performTransition();', 0);		// and flip the widget over	

}

function hidePrefs() {
	widget.setPreferenceForKey(document.getElementById("testSelect").value, "selectedTest");
	startTest();
	
	var front = document.getElementById("front");
	var back = document.getElementById("back");
	
	if (window.widget)
		widget.prepareForTransition("ToFront");		// freezes the widget and prepares it for the flip back to the front
	
	back.style.display="none";			// hide the back
	front.style.display="block";		// show the front
	
	if (window.widget)
		setTimeout ('widget.performTransition();', 0);		// and flip the widget back to the front
}

function next(score) {
	alert("1");
	hideContent();
	alert("2");
	animation.callback = function() {
		alert("4");
		animation.callback = null;
		getAnswerAndScoreIt(score);
		alert("5");
		setTimeout("showContent();",550);
		setTimeout("hideContent();",2000);
		setTimeout("getNewQuestion();",2500);
		setTimeout("showContent();",3000);
	}
	alert("3");
}

var animation = {duration:0, starttime:0, to:1.0, now:1.0, from:0.0, firstElement:null, timer:null};

function showContent() {
alert("wee");
		if (complete)
			return;
			
		if (animation.timer != null) {
			clearInterval (animation.timer);
			animation.timer  = null;
		}
		
		var starttime = (new Date).getTime() - 13; 		// set it back one frame
		
		
		animation.duration = 500;												// animation time, in ms
		animation.starttime = starttime;										// specify the start time
		animation.firstElement = document.getElementById ('ctrTitle');				// specify the element to fade
		animation.timer = setInterval("animate();", 13);						// set the animation function
		animation.from = animation.now;											// beginning opacity (not ness. 0)
		animation.to = 1.0;														// final opacity
		animate();
}

function hideContent() {
		if (complete)
			return;
			
		if (animation.timer != null) {
			clearInterval (animation.timer);
			animation.timer  = null;
		}
		
		var starttime = (new Date).getTime() - 13;
		
		animation.duration = 500;
		animation.starttime = starttime;
		animation.firstElement = document.getElementById ('ctrTitle');
		animation.timer = setInterval ("animate();", 13);
		animation.from = animation.now;
		animation.to = 0.0;
		animate();
}

function animate() {
	var T;
	var ease;
	var time = (new Date).getTime();
	
	T = limit_3(time-animation.starttime, 0, animation.duration);
	
	if (T >= animation.duration) {
		clearInterval (animation.timer);
		animation.timer = null;
		animation.now = animation.to;
		animation.callback();
	} else {
		ease = 0.5 - (0.5 * Math.cos(Math.PI * T / animation.duration));
		animation.now = computeNextFloat (animation.from, animation.to, ease);
	}
	
	animation.firstElement.style.opacity = animation.now;
}

function limit_3 (a, b, c) {
    return a < b ? b : (a > c ? c : a);
}

function computeNextFloat (from, to, ease) {
    return from + (to - from) * ease;
}
/*

File: Stretcher.js

Abstract: Script code for a reusable Stretcher object; expands on 
	the common AppleAnimator class in Mac OS X 10.4.3

Version: 2.0

© Copyright 2005 Apple Computer, Inc. All rights reserved.

IMPORTANT:  This Apple software is supplied to 
you by Apple Computer, Inc. ("Apple") in 
consideration of your agreement to the following 
terms, and your use, installation, modification 
or redistribution of this Apple software 
constitutes acceptance of these terms.  If you do 
not agree with these terms, please do not use, 
install, modify or redistribute this Apple 
software.

In consideration of your agreement to abide by 
the following terms, and subject to these terms, 
Apple grants you a personal, non-exclusive 
license, under Apple's copyrights in this 
original Apple software (the "Apple Software"), 
to use, reproduce, modify and redistribute the 
Apple Software, with or without modifications, in 
source and/or binary forms; provided that if you 
redistribute the Apple Software in its entirety 
and without modifications, you must retain this 
notice and the following text and disclaimers in 
all such redistributions of the Apple Software. 
Neither the name, trademarks, service marks or 
logos of Apple Computer, Inc. may be used to 
endorse or promote products derived from the 
Apple Software without specific prior written 
permission from Apple.  Except as expressly 
stated in this notice, no other rights or 
licenses, express or implied, are granted by 
Apple herein, including but not limited to any 
patent rights that may be infringed by your 
derivative works or by other works in which the 
Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS 
IS" basis.  APPLE MAKES NO WARRANTIES, EXPRESS OR 
IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED 
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY 
AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING 
THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE 
OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY 
SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL 
DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, 
REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF 
THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER 
UNDER THEORY OF CONTRACT, TORT (INCLUDING 
NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN 
IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF 
SUCH DAMAGE.

*/ 

/*
 ***************************************************************
 * <Stretcher object definition.  Stretches a div up and down> *
 ***************************************************************
 */

/*
 * Stretcher constructor; parameters:
 *
 * -- element: The element to stretch
 * -- stretchDistance: Distance (in pixels) the content should stretch
 * -- stretchDuration: How long (in ms) the stretch animation should take
 * -- onFinished: A callback (if no callback is needed, pass null)
 *
 */
function Stretcher (element, stretchDistance, stretchDuration, onFinished) {
	this.element = element;	
	this.stretchDistance = stretchDistance;
	this.duration = stretchDuration;
	this.onFinished = onFinished;

	this.multiplier = 1;	
	
	// min and max position can be changed to alter the stretched/shrunk sizes;
	// getComputedStyle depends on the target (in this case, the stretcher element)
	// being visible, so don't instantiate the Stretcher until the content is shown
	this.minPosition = parseInt(document.defaultView.getComputedStyle(this.element, "").getPropertyValue("height"));
	this.maxPosition = this.minPosition + this.stretchDistance;
	
	// Set variables to what they'd be in the beginning "shrunk" state
	this.positionFrom = this.minPosition;
	this.positionTo = this.maxPosition;
		
	// new AppleClasses support
	var self = this; // eliminates scope problems in timers/event handlers
	
	this.stretchAnimator = null;
			
	// AppleAnimation callback; this is where we actually change the size
	this.nextFrame = function (animation, now, first, done) {
		self.element.style.height = now + "px";
	}
	
	this.changeDirection = function () {
		if (self.positionTo == self.maxPosition) {
			self.positionTo = self.minPosition;
		} else {
			self.positionTo = self.maxPosition;
		}
	}
	
	// Callback for AppleAnimator; also called to interrupt a stretch-in-progress
	this.doneStretching = function () {
		// If we've just shrunk, resize the window to the new AFTER the animation is complete
		if (window.widget && (parseInt(self.element.style.height) == self.minPosition)) {
			window.resizeTo(parseInt(document.defaultView.getComputedStyle(self.element, "").getPropertyValue("width")), self.minPosition);
		}
		self.positionFrom = parseInt(self.element.style.height);
		self.changeDirection();
		delete self.stretchAnimator;
		if (self.onFinished) {
			self.onFinished();
		}
	}
}

/*
 * This should only be called via a Stretcher instance, i.e. "instance.stretch(event)"
 * Calling Stretcher_stretch() directly will result in "this" evaluating to the window
 * object, and the function will fail; parameters:
 * 
 * -- event: the mouse click that starts everything off (from an onclick handler)
 *		We check for the shift key to do a slo-mo stretch
 */
Stretcher.prototype.stretch = function (event) {
	if (event && event != undefined && event.shiftKey) {
		// enable slo-mo
		this.multiplier = 10;
	} else this.multiplier = 1;
	
	// if we're currently stretching
	if (this.stretchAnimator) {
		this.stretchAnimator.stop();
		var handler = this.onFinished;
		this.onFinished = null;
		this.doneStretching();
		this.onFinished = handler;
	} 
	
	// Resize the window before stretching to make room for the newly-sized content
	if (window.widget && (this.positionTo == this.maxPosition)) {
		window.resizeTo(parseInt(document.defaultView.getComputedStyle(this.element, "").getPropertyValue("width")), this.positionTo);
	}
	this.stretchAnimator = new AppleAnimator(this.duration * this.multiplier, 13, this.positionFrom, this.positionTo, this.nextFrame);
	this.stretchAnimator.oncomplete = this.doneStretching;
	this.stretchAnimator.start();
}
	

/*
 * Report whether or not the Stretcher is in its maximized position
 * DO NOT call this function to determine whether or not the Stretcher is 
 * currently animating; set the onFinished handler to be notified when animation
 * is complete
 */
Stretcher.prototype.isStretched = function() {
	return (parseInt(this.element.style.height) == this.maxPosition);
}

/*
 ************************************************************************
 * Debug code uses the div defined in Scroller.html/Scroller.css demo	*
 ************************************************************************
 */
var debugMode = false;

// write to the debug div
function DEBUG(str) {
	if (debugMode) {
		if (window.widget) {
			alert(str);
		} else {
			var debugDiv = document.getElementById("debugDiv");
			debugDiv.appendChild(document.createTextNode(str));
			debugDiv.appendChild(document.createElement("br"));
			debugDiv.scrollTop = debugDiv.scrollHeight;		
		}
	}
}

// Toggle the debugMode flag, but only show the debugDiv if we're in Safari
function toggleDebug() {
	debugMode = !debugMode;
	if (debugMode == true && !window.widget) {
		document.getElementById("debugDiv").style.display = "block";
	} else {
		document.getElementById("debugDiv").style.display = "none";
	}
}
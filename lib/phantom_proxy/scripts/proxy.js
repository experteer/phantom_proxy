var fs = require('fs');

var framesWorked = 0;
var frameCount = 1;
var frameContent = [];
var masterURL = "";

function evaluateWithVars(page, func, vars)
{
	var fstr = func.toString()
	//console.log(fstr.replace("function () {", "function () {\n"+vstr))
	var evalstr = fstr.replace(
		new RegExp("function \((.*?)\) {"),
		"function $1 {\n" + 
			"var vars = JSON.parse('" + JSON.stringify(vars) + "')\n" +
			"for (var v in vars) window[v] = vars[v]\n" +
		"\n"
	)
	console.log(evalstr)
	return page.evaluate(evalstr)
}

function insertFrames(url) {
	var page = require('webpage').create();
	page.onConsoleMessage = function (msg) { console.log(msg); };
	page.onAlert = function(msg) { console.log(msg);};
	page.onLoadStarted = function () {
		console.log('Start loading final Page...'+url);
	};
	page.open(url, function (status) {
		if (status !== 'success') {
            console.log('FAILED_LOADING_URL: '+url);
        } else {
        	page.evaluate(function () {
        		var framestmp = document.getElementsByTagName('IFRAME');
		      	var frames = []
		      	for (var i=0;i<framestmp.length;i++) {
		      		frames.push(framestmp[i]);
		      	}
		      	//mark iframes
		      	for (var i in frames) {
		      		frames[i].innerHTML = "PHANTOMJS_PROXY_IFRAME"+i;
		      	}
					});
					//replace iframes with their data
					var content = new String(page.content);
					for (var i in frameContent) {
						content = content.replace("PHANTOMJS_PROXY_IFRAME"+i, "<phantomjsframe>"+frameContent[i]+"</phantomjsframe>");
		      }
		      console.log("PHANTOMJS_DOMDATA_WRITE:"+content);
		      console.log('PHANTOMJS_DOMDATA_END');
        }
        console.log('WHATEVER');
        phantom.exit();
  });
};

function exit() {
	framesWorked++;
	if (framesWorked == frameCount)
		insertFrames(masterURL);
}
								
var loadpage = function(url) {
	var page = require('webpage').create();
	page.onConsoleMessage = function (msg) { console.log(msg); };
	//page.onLoadFinished =
	page.onAlert = function(msg) { console.log(msg);};
	page.onLoadStarted = function () {
		console.log('Start loading...'+url);
	};
	page.open(url, function (status) {
		if (status !== 'success') {
            console.log('FAILED_LOADING_URL: '+url);
        } else {
            console.log('LOADED PAGE CONTENT['+url+']\n');
            frameContent.push(page.content);
        }
        console.log('WHATEVER');
        exit();
    });
};

function loadIFrames(page) {
	var frames = page.evaluate(function () {
		var framestmp = document.getElementsByTagName('IFRAME');
		var frames = [];
		for (var i=0;i<framestmp.length;i++) {
			frames.push(framestmp[i].getAttribute('src'));
		}
		return frames;
	});

	for (var i=0;i<frames.length;i++) {
		console.log("Frame: "+i+" : "+frames[i]);
		loadpage(frames[i]);
	}
	frameCount = frames.length+1;
}

function main() {

	if (phantom.args.length < 2) {
		  console.log('Usage: proxy.js <picture filename or none> <load iframe(true/false)> <URL> <url param count> <url params...>');
		  phantom.exit();
	} else {
		file_name = phantom.args[0];
		var loadIframes = phantom.args[1].match(/true/i) ? true : false;
		address = phantom.args[2];

		var argCount = phantom.args[3];

		args = ""

		for (var i=0;i<argCount;i++)
			args += phantom.args[i+4]+'&';
		if (args.length > 0)
			address += '?'+args;

		console.log("Open page: "+address+", "+args+" END");

		var page = require('webpage').create();

		page.onConsoleMessage = function (msg) { console.log(msg); };

		console.log('start openning page');

		masterURL = address;
		
		//catches status != 200 and throws error immidiatly
		page.onResourceReceived = function (response) {
			if (response.stage == "end" && response.url == address && response.status != 200)
			{
				console.log('FAILED_LOADING_URL: '+response.status+'FAILED_LOADING_URL_END');
				//phantom.exit();
			}
		};

		page.open(address, function (status) {
			if (status !== 'success') {
				console.log('FAILED_LOADING_URL');
			} else {
				console.log('DONE_LOADING_URL');
				//load iframes into page
				if (loadIframes) {
					loadIFrames(page);
				}
				//evaluateWithVars(page, function(){}, phantom.args);
				console.log('PHANTOMJS_MAINDOM_WRITE:'+page.content);
				console.log('PHANTOMJS_MAINDOM_END');
			}
			if (file_name != null && file_name != "none") {
				page.render(file_name);
			}
			exit();
		});
	}
}

main();

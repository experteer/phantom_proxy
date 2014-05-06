var fs = require('fs');

var framesWorked = 0;
var frameCount = 1;
var frameContent = [];
var masterURL = "";
var masterPage = null;

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

	var page = masterPage;

  page.evaluate(function () {
    var framestmp = document.getElementsByTagName('IFRAME');
		var frames = [];
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
	//console.log("PHANTOMJS_DOMDATA_WRITE:"+content);
	console.log('PHANTOMJS_DOMDATA_END');

  console.log('WHATEVER');
  phantom.exit();
};

function exit() {
	framesWorked++;
	if (framesWorked == frameCount)
		insertFrames(masterURL);
}
								
var loadpage = function(url, referer, success, failure, configure) {
	var redirectURL = null;

	var page = require('webpage').create();

	page.settings.userAgent = "Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/34.0.1847.116 Chrome/34.0.1847.116 Safari/537.36";

	page.onConsoleMessage = function (msg) { console.log(msg); };

	page.onAlert = function(msg) { console.log(msg);};

	page.onLoadStarted = function () {
		console.log('Start loading...'+url);
	};

	page.onResourceReceived = function(resource) {
    if (url == resource.url && resource.redirectURL && resource.stage == "end") {
      redirectURL = resource.redirectURL;
      console.log('FRAME_URL_ERROR_CODE: '+resource.status+'FRAME_URL_ERROR_CODE_END');
    }
  };
 //  page.onResourceReceived = function (response) {
	// 	console.log('FRAME_URL_ERROR_CODE: '+response.status+','+response.stage+'FRAME_URL_ERROR_CODE_END');
	// };

	if (referer!=undefined) {
		console.log("Set Referer: "+referer);
		page.customHeaders = {
			"Referer": referer
		};
	}

	if (configure != undefined)
		configure(page);

	page.open(url, function (status) {
		console.log("Page Status: "+status);
		if (redirectURL) {
      loadpage(redirectURL, url, success, failure);
    } else if (status !== 'success') {
	    failure(page, url);
    } else {
    	success(page, url);
    }
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

	frameCount = frames.length+1;

	for (var i=0;i<frames.length;i++) {
		console.log("Frame: "+i+" : "+frames[i]);
		loadpage(frames[i], masterURL,
			function(page, url) {
				page.reload();
				console.log('LOADED PAGE CONTENT['+url+']['+page.content+']\n');
	    	frameContent.push(page.content);
		    exit();
			},
			function(page, url){
				console.log('FAILED_LOADING_URL: ['+url+']['+page.content+']\n');
				console.log('WHATEVER');
				exit();
			}
		);
	}
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

		for (var i=0;i<argCount;i++) {
			args += phantom.args[i+4];
			if (i<argCount-1) args += "&"
		}
		if (args.length > 0)
			address += '?'+args;

		console.log("Open page: "+address+", "+args+" END");

		console.log('start openning page');

		masterURL = address;

		loadpage(address, undefined, function(page) {
			masterPage = page;
			console.log('DONE_LOADING_URL');
			//load iframes into page
			if (loadIframes) {
				loadIFrames(page);
			}
			if (file_name != null && file_name != "none") {
				page.render(file_name);
			}
			exit();
		}, function(page) {
			masterPage = page;
			console.log('FAILED_LOADING_URL: '+status+", "+address);
			if (file_name != null && file_name != "none") {
				page.render(file_name);
			}
			exit();
		}, function(page) {
			//page.customHeaders = {"Referer": "http://uk-amazon.icims.com/jobs/240290/account-representative---amazon-web-services---iberia/job"}
			// page.onResourceReceived = function (response) {
			// 	if (response.stage == "end" && response.url == address && response.status != 200)
			// 	{
			// 		console.log('URL_ERROR_CODE: '+response.status+'URL_ERROR_CODE_END');
			// 	}
			// };
		});
	}
}

main();

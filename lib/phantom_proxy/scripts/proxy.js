var fs = require('fs');

var framesWorked = 0;
var frameCount = 1;
var frameContent = [];
var visited_pages = [];
var masterURL = "";
var masterPage = null;

function newIFrameLoad(page, load_iframes) {
  var frame_data = [];
  if (load_iframes) {
    frame_data = page.evaluate(function () {
      var framestmp = document.getElementsByTagName('IFRAME');
      var frames = [];
      for (var i=0;i<framestmp.length;i++) {
        if (framestmp[i].contentWindow && framestmp[i].contentWindow.document && framestmp[i].contentWindow.document.body) {
          frames.push(framestmp[i].contentWindow.document.body.innerHTML);
          framestmp[i].outerHTML = "<phantomjsframe>PHANTOM_JS_FRAME_"+i+"</phantomjsframe>";
        }
      }
      return frames;
    }) || []; //This stops the code from crashing incase there is an exception during page eval
  }
  var content = new String(page.content);
  for (var i=0;i<frame_data.length;i++) {
    content = content.replace("PHANTOM_JS_FRAME_"+i, frame_data[i]);
  }
  console.log("PHANTOMJS_DOMDATA_WRITE:"+content);
  console.log('PHANTOMJS_DOMDATA_END');
}

var loadpage = function(url, referer, success, failure, configure) {
  var redirectURL = null;

  var page = require('webpage').create();

  page.settings.localToRemoteUrlAccessEnabled = true;

  page.settings.resourceTimeout = 40000;

  page.onResourceTimeout = function(request) {
    console.log('Response (#' + request.id + '): ' + JSON.stringify(request));
  };

  page.settings.userAgent = "Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/34.0.1847.116 Chrome/34.0.1847.116 Safari/537.36";

  page.onConsoleMessage = function (msg) { console.log(msg); };

  page.onAlert = function(msg) { console.log(msg);};

  page.onLoadStarted = function () {
    console.log('Start loading...'+url);
  };

  page.onResourceReceived = function(resource) {
    if (url == resource.url && resource.redirectURL && resource.stage == "end") {
      redirectURL = resource.redirectURL;
      console.log('URL_FRAME_ERROR_CODE: '+resource.status+'URL_FRAME_ERROR_CODE_END');
    } else if (url == resource.url && resource.stage == "end" && resource.status != 200 && (referer!=undefined || !resource.redirectURL)) {
      console.log('URL_ERROR_CODE: '+resource.status+'URL_ERROR_CODE_END');
    }
  };

  if (referer!=undefined) {
    console.log("Set Referer: "+referer);
    page.customHeaders = {
      "REFERER": referer
    };
  }

  if (configure != undefined)
    configure(page);

  page.viewportSize = { width: 1920, height: 1080 };
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
      newIFrameLoad(page, loadIframes);
      if (file_name != null && file_name != "none") {
        page.render(file_name);
      }
      phantom.exit();
    }, function(page) {
      masterPage = page;
      console.log('FAILED_LOADING_URL: '+status+", "+address);
      if (file_name != null && file_name != "none") {
        page.render(file_name);
      }
      phantom.exit();
    }, function(page) {
      //page.customHeaders = {"Referer": "http://uk-amazon.icims.com/jobs/240290/account-representative---amazon-web-services---iberia/job"}
      // page.onResourceReceived = function (response) {
      //  if (response.stage == "end" && response.url == address && response.status != 200)
      //  {
      //    console.log('URL_ERROR_CODE: '+response.status+'URL_ERROR_CODE_END');
      //  }
      // };
    });
  }
}

main();

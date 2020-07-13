(function (global, document) {
  "use strict";

  // Get self details.
  global.selfGet = function (callback) {
    var json = {
      ownerToken: global.cookieGet("accessToken"),
    };

    if (json.ownerToken === undefined) {
      document.location = "/login?redirect=/comments/dashboard";
      return;
    }

    global.post(global.origin + "/api/owner/self", json, function (resp) {
      if (!resp.success || !resp.loggedIn) {
        global.cookieDelete("accessToken");
        document.location = "/login?redirect=/comments/dashboard";
        return;
      }

      global.owner = resp.owner;
      callback();
    });
  };
})(window.commento, document);

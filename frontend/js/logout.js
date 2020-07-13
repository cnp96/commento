(function (global, document) {
  "use strict";

  global.logout = function () {
    global.cookieDelete("accessToken");
    document.location = "/login?redirect=/comments/dashboard";
  };
})(window.commento, document);

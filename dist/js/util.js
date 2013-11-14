// Generated by CoffeeScript 1.6.3
(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : window;

  root.util = {
    getFromLocalStorage: function(key) {
      var value;
      value = localStorage[key];
      if (value) {
        return JSON.parse(value);
      }
      return null;
    },
    putInLocalStorage: function(key, value) {
      return localStorage[key] = JSON.stringify(value);
    },
    defaultResponse: function(sendResponse) {
      return sendResponse({
        OK: true
      });
    },
    isBlank: function(str) {
      return !str || /^\s*$/.test(str);
    },
    convertToBackboneArr: function(Model, arr) {
      return _.map(arr, function(item) {
        return new Model(item);
      });
    },
    saveToBg: function(key, model) {
      var req;
      req = {};
      req[key] = model.toJSON();
      return chrome.extension.sendMessage(req);
    },
    highlight: function($el) {
      return $el.effect('highlight', {
        color: '#A9F5BC'
      }, 500);
    },
    uncapitalize: function(str) {
      str = str == null ? "" : String(str);
      return str.charAt(0).toLowerCase() + str.slice(1);
    }
  };

}).call(this);

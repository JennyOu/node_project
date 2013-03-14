(function() {
  var $, hasLocalStorage, isAvailable, now;

  hasLocalStorage = window['localStorage'] != null;

  $ = jQuery;

  $.storage = {
    set: function(key, data, ttl) {
      var storage;
      if (hasLocalStorage) {
        storage = {
          data: data,
          ttl: ttl || 0,
          createTime: now()
        };
        return localStorage.setItem(key, JSON.stringify(storage));
      } else {
        if (ttl) {
          $.cookies.setOptions({
            hoursToLive: ttl / 3600
          });
        }
        return $.cookies.set(key, data);
      }
    },
    get: function(key) {
      var storage;
      if (hasLocalStorage) {
        storage = localStorage.getItem(key);
        if (!storage) {
          return null;
        }
        storage = JSON.parse(storage);
        if (isAvailable(storage)) {
          return storage.data;
        }
        localStorage.removeItem(key);
        return null;
      } else {
        return $.cookies.get(key);
      }
    },
    del: function(key) {
      if (hasLocalStorage) {
        return localStorage.removeItem(key);
      } else {
        return $.cookies.del(key);
      }
    }
  };

  now = Date.now || function() {
    return new Date().getTime();
  };

  isAvailable = function(storage) {
    var ttl;
    ttl = storage.ttl;
    if (!ttl) {
      return true;
    }
    if (ttl * 1000 + storage.createTime >= now()) {
      return true;
    }
    return false;
  };

}).call(this);

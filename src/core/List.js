// Generated by CoffeeScript 1.10.0
(function() {
  var EMPTY, List;

  EMPTY = {
    find: function() {
      return null;
    },
    con: function(value) {
      return new List(value, EMPTY);
    }
  };

  List = function(value1, next) {
    this.value = value1;
    this.next = next != null ? next : EMPTY;
  };

  List.prototype.find = function(value) {
    if (this.value === value) {
      return this;
    } else {
      return this.next.find(value);
    }
  };

  List.prototype.con = function(value) {
    return new List(value, this);
  };

  List.EMPTY = EMPTY;

  if (window.bef == null) {
    window.bef = {};
  }

  window.bef.List = List;

}).call(this);

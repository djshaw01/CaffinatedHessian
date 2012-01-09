var HessianConnection, encodeBoolean, encodeDouble, encodeInt, encodeKV, encodeLength, encodeList, encodeLong, encodeObject, encodeString, encodeTypeName, flatten, getName, isInt, isLong, printHex, process, toByte, _encodeInt, _encodeObject, _process;
var __slice = Array.prototype.slice;
Array.prototype.cons = function() {
  var lol, other, _i, _len;
  lol = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  for (_i = 0, _len = lol.length; _i < _len; _i++) {
    other = lol[_i];
    Array.prototype.push.apply(this, other);
  }
  return this;
};
isInt = function(n) {
  var a;
  a = 0x7FFFFFFF;
  return (n > ~a && n < a) && (n % 1 === 0);
};
isLong = function(n) {
  return n % 1 === 0;
};
encodeBoolean = function(bArg) {
  if (bArg) {
    return ["T"];
  } else {
    return ["F"];
  }
};
_encodeInt = function(i) {
  var lc, _results;
  _results = [];
  for (lc = 24; lc >= 0; lc += -8) {
    _results.push((i >> lc) & 0xff);
  }
  return _results;
};
encodeInt = function(i) {
  return ["I".charCodeAt(0)].cons(_encodeInt(i));
};
encodeLong = function(l) {
  var hex, high, len, low;
  hex = l.toString(16);
  len = hex.length;
  high = parseInt("0x" + hex.substr(0, len - 8));
  low = parseInt("0x" + hex.substr(len - 8));
  return ["L".charCodeAt(0)].cons([_encodeInt(high), _encodeInt(low)]);
};
toByte = function(bitStr) {
  return parseInt(bitStr, 2);
};
encodeDouble = function(dbl) {
  var bits, s;
  bits = CvtFwd(dbl);
  return ["D".charCodeAt(0)].cons((function() {
    var _results;
    _results = [];
    for (s = 0; s <= 56; s += 8) {
      _results.push(toByte(bits.substr(s, 8)));
    }
    return _results;
  })());
};
encodeList = function(list) {
  return ["V".charCodeAt(0)].cons(process.apply(null, list));
};
encodeString = function(s) {
  var a;
  return ["S".charCodeAt(0)].cons(encodeLength(s.length).cons((function() {
    var _i, _len, _ref, _results;
    _ref = s.split('');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      a = _ref[_i];
      _results.push(a.charCodeAt(0));
    }
    return _results;
  })()));
};
encodeLength = function(i) {
  var lc, _results;
  _results = [];
  for (lc = 8; lc >= 0; lc += -8) {
    _results.push((i >> lc) & 0xff);
  }
  return _results;
};
encodeObject = function(obj) {
  if (obj.length != null) {
    return encodeList(obj);
  } else {
    return _encodeObject(obj);
  }
};
_encodeObject = function(obj) {
  var k, name, v;
  name = getName(obj);
  if (name === "Object") {
    return ["M".charCodeAt(0)].cons((function() {
      var _results;
      _results = [];
      for (k in obj) {
        v = obj[k];
        _results.push(encodeKV(k, v));
      }
      return _results;
    })());
  } else {
    return ["M".charCodeAt(0)].cons(encodeTypeName(getName(obj)).cons((function() {
      var _results;
      _results = [];
      for (k in obj) {
        v = obj[k];
        _results.push(encodeKV(k, v));
      }
      return _results;
    })()));
  }
};
encodeKV = function(k, v) {
  return encodeString(k).cons(_process(v));
};
encodeTypeName = function(name) {
  var a;
  return ["t".charCodeAt(0)].cons(encodeLength(name.length).cons((function() {
    var _i, _len, _ref, _results;
    _ref = name.split('');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      a = _ref[_i];
      _results.push(a.charCodeAt(0));
    }
    return _results;
  })()));
};
getName = function(o) {
  var a, _ref;
  a = /^function (.{1,})\(/.exec(o.constructor.toString());
  return (_ref = a[1]) != null ? _ref : "";
};
_process = function(arg) {
  switch (typeof arg) {
    case "boolean":
      return encodeBoolean(arg);
    case "number":
      if (isInt(arg)) {
        return encodeInt(arg);
      } else if (isLong(arg)) {
        return encodeLong(arg);
      } else {
        return encodeDouble(arg);
      }
      break;
    case "string":
      return encodeString(arg);
    case "object":
      return encodeObject(arg);
  }
};
process = function() {
  var arg, args;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  return flatten((function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      arg = args[_i];
      _results.push(_process(arg));
    }
    return _results;
  })());
};
printHex = function(i) {
  return "0x" + i.toString(16);
};
flatten = function(l) {
  if (!(l instanceof Array)) {
    return [l];
  } else {
    return $.map(l, flatten);
  }
};
HessianConnection = (function() {
  function HessianConnection() {}
  HessianConnection.proxy = function(url, obj) {
    var key, value, _ref;
    _ref = obj.prototype;
    for (key in _ref) {
      value = _ref[key];
      obj[key] = function() {
        var args, sargs, xhr;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        xhr = this.xmlhttp;
        sargs = process.apply(null, args);
        xhr.open('POST', url, true);
        if ('overrideMimeType' in xhr) {
          xhr.overrideMimeType('text/plain; charset=x-user-defined');
        }
        xhr.onreadystatechange = function() {
          if (xhr.readyState === 4) {
            return alert(xhr.responseText);
          }
        };
        alert(sargs.join(""));
        return xhr.send(sargs.join(""));
      };
    }
    obj['xmlhttp'] = new (window.ActiveXObject || XMLHttpRequest)('Microsoft.XMLHTTP');
    return obj;
  };
  return HessianConnection;
})();
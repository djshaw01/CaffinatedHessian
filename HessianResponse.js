(function() {
  var HessianFault, HessianResponse;
  HessianFault = (function() {
    function HessianFault() {}
    HessianFault.code;
    HessianFault.message;
    HessianFault.detail;
    return HessianFault;
  })();
  HessianResponse = (function() {
    HessianResponse.state = '';
    HessianResponse.offest;
    HessianResponse.ch;
    HessianResponse.parsed;
    HessianResponse.prototype.STATE = {
      INIT: '',
      REPLY: 'r',
      FAULT: 'f',
      MAP: 'M',
      TERM: 'z',
      STR: 'S',
      LIST: 'V',
      NULL: 'N',
      LEN: 'l',
      BOOL: 'T',
      INT: 'I',
      LONG: 'L',
      DUB: 'D',
      DATE: 'd',
      STR: 'S',
      XML: 'x',
      BIN: 'B',
      REF: 'R'
    };
    function HessianResponse(ch) {
      this.ch = ch;
    }
    HessianResponse.prototype.parse = function() {
      this.offset = 0;
      this.parsech;
      return unit;
    };
    HessianResponse.prototype.parsech = function() {
      var obj, _results;
      this.state = this.prototype.STATE[INIT];
      _results = [];
      while (this.offset < this.ch.length) {
        _results.push((function() {
          switch (ch) {
            case this.prototype.STATE[REPLY]:
              return this.offset += 3;
            case this.prototype.STATE[FAULT]:
              return 1;
            case 'M':
              obj = parseMap(buffer.slice(offset, buffer.length));
              return offset += len;
          }
        }).call(this));
      }
      return _results;
    };
    HessianResponse.prototype.parseFault = function() {
      var code, detail, h, message;
      this.parsed = new HessianFault();
      code = parseString;
      if (code === "code") {
        this.parsed.code = parseString;
      }
      message = parseString;
      if (message === "message") {
        this.parsed.message = parseString;
      }
      detail = parseString;
      if (detail === "detail") {
        h = new HessianResponse(ch.slice(offset, (ch.length - 1 + 1) || 9e9));
        h.parse;
        return this.parsed.detail = h.parsed;
      }
    };
    return HessianResponse;
  })();
}).call(this);

Array::cons = (lol...) ->
    Array::push.apply(@, other) for other in lol
    @

isInt = (n) ->
    a = 0x7FFFFFFF
    (n > ~a && n < a) and (n % 1 is 0)
    
isLong = (n) ->
    n % 1 is 0;

encodeBoolean = (bArg) ->
    if(bArg) then ["T"] else ["F"]

_encodeInt = (i) ->
    ((i>>lc)&0xff for lc in [24..0] by -8)

    
encodeInt = (i) ->
    ["I".charCodeAt(0)].cons _encodeInt(i)

encodeLong = (l) ->
    hex = l.toString(16)
    len = hex.length
    high = parseInt("0x" + hex.substr(0,len-8))
    low = parseInt("0x" + hex.substr(len-8))
    ["L".charCodeAt(0)].cons [_encodeInt(high),_encodeInt(low)]

toByte = (bitStr) ->
    parseInt(bitStr,2)

encodeDouble = (dbl) ->
    bits = CvtFwd(dbl)
    ["D".charCodeAt(0)].cons (toByte(bits.substr(s,8)) for s in [0..56] by 8)

encodeList = (list) ->
    ["V".charCodeAt(0)].cons (process(list...))

_encodeString = (s) ->
    encodeLength(s.length).cons (a.charCodeAt(0) for a in s.split '')
    
encodeString = (s) ->
    ["S".charCodeAt(0)].cons _encodeString(s)

encodeLength =(i) ->
    ((i>>lc)&0xff for lc in [8..0] by -8)
    
encodeObject =(obj) ->
    l = if obj.length? then encodeList(obj) else _encodeObject(obj) 
    l.cons ["z".charCodeAt(0)]

_encodeObject =(obj) ->
    name = getName(obj)
    if(name == "Object")
        ["M".charCodeAt(0)].cons (encodeKV(k,v) for k,v of obj)
    else
        ["M".charCodeAt(0)].cons encodeTypeName(getName(obj)).cons (encodeKV(k,v) for k,v of obj)
    

encodeKV =(k,v) ->
    encodeString(k).cons _process(v)

encodeTypeName =(name) ->
    ["t".charCodeAt(0)].cons _encodeString(name)
    
getName =(o) ->
    a = /^function (.{1,})\(/.exec o.constructor.toString()
    a[1] ? ""


_process = (arg) ->
    switch typeof(arg)
        when "boolean" then encodeBoolean(arg)
        when "number" 
            if isInt arg
                encodeInt(arg)
            else if isLong arg
                encodeLong(arg)
            else
                encodeDouble(arg)
        when "string" then encodeString(arg)
        when "object" then encodeObject(arg)

process = (args...) ->
    flatten(_process(arg) for arg in args)
    
    
printHex = (i) ->
    sprintf("0x%02x: %c",i, i)
    
flatten = (l) -> 
    if (!(l instanceof Array)) then [l] else $.map(l, flatten);
    
_constructCall = (method,args...) ->
    ["c".charCodeAt(0)].cons [1,0].cons ["m".charCodeAt(0)].cons _encodeString(method).cons process(args...).cons ["z".charCodeAt(0)]

constructCall = (method,args...) ->
    flatten(_constructCall(method,args...))

toChars = (a) ->
    (String.fromCharCode(code) for code in a)
    
class HessianConnection
    @proxy: (url,obj) ->
        for key, value of obj.prototype
            obj[key] = (args...) -> 
                xhr = this.xmlhttp
                sargs = toChars(constructCall(key,args...))
                
                xhr.open 'POST', url, false
                xhr.overrideMimeType 'text/plain; charset=x-user-defined' if 'overrideMimeType' of xhr
                xhr.send sargs.join("")
                xhr.responseText


        obj['xmlhttp'] = new (window.ActiveXObject or XMLHttpRequest)('Microsoft.XMLHTTP')
        obj


        

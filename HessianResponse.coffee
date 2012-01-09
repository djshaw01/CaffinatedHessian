#top     ::= call
#        ::= replycall    ::= c x01 x00 header* methodobject* z
#
#reply   ::= r x01 x00 header* object z
#        ::= r x01 x00 header* fault z
#
#object  ::= null
#        ::= boolean
#        ::= int
#        ::= long
#        ::= double
#        ::= date
#        ::= string
#        ::= xml
#        ::= binary
#        ::= remote
#        ::= ref
#        ::= list
#        ::= mapheader  ::= H b16 b8 header-string objectmethod  ::= m b16 b8 method-string
#
#fault   ::= f (objectobject)* z
#
#list    ::= V type? length? object* z
#map     ::= M type? (objectobject)* z
#remote  ::= r type? stringtype    ::= t b16 b8 type-string
#length  ::= l b32 b24 b16 b8
#
#null    ::= N
#boolean ::= T
#        ::= F
#int     ::= I b32 b24 b16 b8
#long    ::= L b64 b56 b48 b40 b32 b24 b16 b8
#double  ::= D b64 b56 b48 b40 b32 b24 b16 b8
#date    ::= d b64 b56 b48 b40 b32 b24 b16 b8
#string  ::= (s b16 b8 string-data)* S b16 b8 string-data
#xml     ::= (x b16 b8 xml-data)* X b16 b8 xml-data
#binary  ::= (b b16 b8 binary-data)* B b16 b8 binary-data
#ref     ::= R b32 b24 b16 b8


class HessianFault
    @code
    @message
    @detail
    

class HessianResponse
    @state = ''
    @offest
    @ch
    @parsed
    @::STATE = 
        INIT:''
        REPLY:'r'
        FAULT:'f'
        MAP:'M'
        TERM:'z'
        STR:'S'
        LIST:'V'
        NULL:'N'
        LEN:'l'
        BOOLT:'T'
        BOOLF:'F'
        INT:'I'
        LONG:'L'
        DUB:'D'
        DATE:'d'
        STR:'S'
        XML:'x'
        BIN:'B'
        REF:'R'
    constructor: (@ch) ->
    
    parse: ->
        @offset = 0;
        @.parsech
        1
    
    parsech: ->
        @state = @::STATE[INIT]
        while(@offset < @ch.length)
            switch ch
                when @::STATE[REPLY] then @offset += 3
                when @::STATE[FAULT] then parseFault # alert("fault")
                when @::STATE[MAP] then parseMap
                
    
#  r x01 x00
#  f
#  S x00 x04 code
#  S x00 x10 ServiceException
#
#  S x00 x07 message
#  S x00 x0e File Not Found
#
#  S x00 x06 detail
#  M t x00 x1d java.io.FileNotFoundException
#    z
    parseFault: ->
        @parsed = new HessianFault()
        code = parseString;
        if(code == "code")
            @parsed.code = parseString
        message = parseString
        if(message == "message")
            @parsed.message = parseString
        detail = parseString
        if(detail == "detail")
            h = new HessianResponse(@ch[@offset..@ch.length-1]) #minus the last z
            h.parse
            @parsed.detail = h.parsed
        @parsed

    parseNumeric: (len) ->
        o = @offset;
        @offset += len
        num = 0
        shft = Math.pow(2,len) - 8
        for i in [0..len]
            num |= parseInt(@ch[i].charCodeAt(0)) << shft
            shft -= 8
        num
    # Parses the short value string legth for Strings and types
    parseShort: ->
        o = @offset + 1
        @offset += 3
        @.parseNumeric(2)

#string  ::= (s b16 b8 string-data)* S b16 b8 string-data
    parseString: ->
        chr = @ch[@offset].charCodeAt(0)
        if(chr == 'S')
            len = parseShort
            o = @offset
            @offset += len
            @ch[o...o+len].join("")
        else
            throw new Error("Unexpected type in HessianResponse.parseString")

#length  ::= l b32 b24 b16 b8
#int     ::= I b32 b24 b16 b8
    parseInt: ->    #parses and Integer or length
        chr = @ch[@offset].charCodeAt(0)
        if(chr == 'I' || chr == 'l')
            @offset += 5
            @.parseNumeric(4)
        else
            throw new Error("Unexpected type in HessianResponse.parseInt");

#long    ::= L b64 b56 b48 b40 b32 b24 b16 b8
    parseLong: ->
        chr = @ch[@offset].charCodeAt(0)
        if(chr == 'L')
            @offset += 9
            high = parseNumeric(4);
            low = parseNumeric(4)
            parseInt("0x" + high.toString(16) + low.toString(16),16)
        else
            throw new Error("Unexpected type in HessianResponse.parseLong")
            
#double  ::= D b64 b56 b48 b40 b32 b24 b16 b8
    parseDouble: ->
        chr = @ch[@offset].charCodeAt(0)
        if(chr == 'D')
            @offset += 9
            high = parseNumeric(4);
            low = parseNumeric(4)
            _parseDouble(high,low)
        else
            throw new Error("Unexpected type in HessianResponse.parseDouble")
    
    
    
    _parseDouble: (high,low) ->
        p32 = 0x100000000;
        p52 = 0x10000000000000;

        exp = (high >> 20) & 0x7ff;
        sign = (high >> 31);
        m = 1 + ((high & 0xfffff) * p32 + low) / p52
        m = if exp then (m + 1) else (m * 2.0)
        (sign ? -1 : 1) * m * Math.pow(2, exp - 1023)

#boolean ::= T
#        ::= F
    parseBoolean: ->
        chr = @ch[@offset].charCodeAt(0)
        if(chr == 'T' || chr == 'F')
            @offset += 1
            if chr == 'T' then true else false
        else
            throw new Error("Unexpected type in HessianResponse.parseBoolean")

#list    ::= V type? length? object* z
#map     ::= M type? (objectobject)* z
#remote  ::= r type? stringtype    ::= t b16 b8 type-string
#
#null    ::= N
#date    ::= d b64 b56 b48 b40 b32 b24 b16 b8
#xml     ::= (x b16 b8 xml-data)* X b16 b8 xml-data
#binary  ::= (b b16 b8 binary-data)* B b16 b8 binary-data
#ref     ::= R b32 b24 b16 b8    
#  z  
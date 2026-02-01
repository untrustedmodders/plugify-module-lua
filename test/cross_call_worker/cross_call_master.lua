-- Generated from cross_call_master.pplugin

-- Enum: Example
Example = {
  First = 1,
  Second = 2,
  Third = 3,
  Forth = 4,
}


--- ReverseReturn
-- @param returnString string 
function ReverseReturn(returnString) end

--- NoParamReturnVoidCallback
function NoParamReturnVoidCallback() end

--- NoParamReturnBoolCallback
-- @return bool 
function NoParamReturnBoolCallback() end

--- NoParamReturnChar8Callback
-- @return char8 
function NoParamReturnChar8Callback() end

--- NoParamReturnChar16Callback
-- @return char16 
function NoParamReturnChar16Callback() end

--- NoParamReturnInt8Callback
-- @return int8 
function NoParamReturnInt8Callback() end

--- NoParamReturnInt16Callback
-- @return int16 
function NoParamReturnInt16Callback() end

--- NoParamReturnInt32Callback
-- @return int32 
function NoParamReturnInt32Callback() end

--- NoParamReturnInt64Callback
-- @return int64 
function NoParamReturnInt64Callback() end

--- NoParamReturnUInt8Callback
-- @return uint8 
function NoParamReturnUInt8Callback() end

--- NoParamReturnUInt16Callback
-- @return uint16 
function NoParamReturnUInt16Callback() end

--- NoParamReturnUInt32Callback
-- @return uint32 
function NoParamReturnUInt32Callback() end

--- NoParamReturnUInt64Callback
-- @return uint64 
function NoParamReturnUInt64Callback() end

--- NoParamReturnPointerCallback
-- @return ptr64 
function NoParamReturnPointerCallback() end

--- NoParamReturnFloatCallback
-- @return float 
function NoParamReturnFloatCallback() end

--- NoParamReturnDoubleCallback
-- @return double 
function NoParamReturnDoubleCallback() end

--- NoParamReturnFunctionCallback
-- @return function 
function NoParamReturnFunctionCallback() end

--- NoParamReturnStringCallback
-- @return string 
function NoParamReturnStringCallback() end

--- NoParamReturnAnyCallback
-- @return any 
function NoParamReturnAnyCallback() end

--- NoParamReturnArrayBoolCallback
-- @return bool[] 
function NoParamReturnArrayBoolCallback() end

--- NoParamReturnArrayChar8Callback
-- @return char8[] 
function NoParamReturnArrayChar8Callback() end

--- NoParamReturnArrayChar16Callback
-- @return char16[] 
function NoParamReturnArrayChar16Callback() end

--- NoParamReturnArrayInt8Callback
-- @return int8[] 
function NoParamReturnArrayInt8Callback() end

--- NoParamReturnArrayInt16Callback
-- @return int16[] 
function NoParamReturnArrayInt16Callback() end

--- NoParamReturnArrayInt32Callback
-- @return int32[] 
function NoParamReturnArrayInt32Callback() end

--- NoParamReturnArrayInt64Callback
-- @return int64[] 
function NoParamReturnArrayInt64Callback() end

--- NoParamReturnArrayUInt8Callback
-- @return uint8[] 
function NoParamReturnArrayUInt8Callback() end

--- NoParamReturnArrayUInt16Callback
-- @return uint16[] 
function NoParamReturnArrayUInt16Callback() end

--- NoParamReturnArrayUInt32Callback
-- @return uint32[] 
function NoParamReturnArrayUInt32Callback() end

--- NoParamReturnArrayUInt64Callback
-- @return uint64[] 
function NoParamReturnArrayUInt64Callback() end

--- NoParamReturnArrayPointerCallback
-- @return ptr64[] 
function NoParamReturnArrayPointerCallback() end

--- NoParamReturnArrayFloatCallback
-- @return float[] 
function NoParamReturnArrayFloatCallback() end

--- NoParamReturnArrayDoubleCallback
-- @return double[] 
function NoParamReturnArrayDoubleCallback() end

--- NoParamReturnArrayStringCallback
-- @return string[] 
function NoParamReturnArrayStringCallback() end

--- NoParamReturnArrayAnyCallback
-- @return any[] 
function NoParamReturnArrayAnyCallback() end

--- NoParamReturnArrayVector2Callback
-- @return vec2[] 
function NoParamReturnArrayVector2Callback() end

--- NoParamReturnArrayVector3Callback
-- @return vec3[] 
function NoParamReturnArrayVector3Callback() end

--- NoParamReturnArrayVector4Callback
-- @return vec4[] 
function NoParamReturnArrayVector4Callback() end

--- NoParamReturnArrayMatrix4x4Callback
-- @return mat4x4[] 
function NoParamReturnArrayMatrix4x4Callback() end

--- NoParamReturnVector2Callback
-- @return vec2 
function NoParamReturnVector2Callback() end

--- NoParamReturnVector3Callback
-- @return vec3 
function NoParamReturnVector3Callback() end

--- NoParamReturnVector4Callback
-- @return vec4 
function NoParamReturnVector4Callback() end

--- NoParamReturnMatrix4x4Callback
-- @return mat4x4 
function NoParamReturnMatrix4x4Callback() end

--- Param1Callback
-- @param a int32 
function Param1Callback(a) end

--- Param2Callback
-- @param a int32 
-- @param b float 
function Param2Callback(a, b) end

--- Param3Callback
-- @param a int32 
-- @param b float 
-- @param c double 
function Param3Callback(a, b, c) end

--- Param4Callback
-- @param a int32 
-- @param b float 
-- @param c double 
-- @param d vec4 
function Param4Callback(a, b, c, d) end

--- Param5Callback
-- @param a int32 
-- @param b float 
-- @param c double 
-- @param d vec4 
-- @param e int64[] 
function Param5Callback(a, b, c, d, e) end

--- Param6Callback
-- @param a int32 
-- @param b float 
-- @param c double 
-- @param d vec4 
-- @param e int64[] 
-- @param f char8 
function Param6Callback(a, b, c, d, e, f) end

--- Param7Callback
-- @param a int32 
-- @param b float 
-- @param c double 
-- @param d vec4 
-- @param e int64[] 
-- @param f char8 
-- @param g string 
function Param7Callback(a, b, c, d, e, f, g) end

--- Param8Callback
-- @param a int32 
-- @param b float 
-- @param c double 
-- @param d vec4 
-- @param e int64[] 
-- @param f char8 
-- @param g string 
-- @param h char16 
function Param8Callback(a, b, c, d, e, f, g, h) end

--- Param9Callback
-- @param a int32 
-- @param b float 
-- @param c double 
-- @param d vec4 
-- @param e int64[] 
-- @param f char8 
-- @param g string 
-- @param h char16 
-- @param k int16 
function Param9Callback(a, b, c, d, e, f, g, h, k) end

--- Param10Callback
-- @param a int32 
-- @param b float 
-- @param c double 
-- @param d vec4 
-- @param e int64[] 
-- @param f char8 
-- @param g string 
-- @param h char16 
-- @param k int16 
-- @param l ptr64 
function Param10Callback(a, b, c, d, e, f, g, h, k, l) end

--- ParamRef1Callback
-- @param a int32 
function ParamRef1Callback(a) end

--- ParamRef2Callback
-- @param a int32 
-- @param b float 
function ParamRef2Callback(a, b) end

--- ParamRef3Callback
-- @param a int32 
-- @param b float 
-- @param c double 
function ParamRef3Callback(a, b, c) end

--- ParamRef4Callback
-- @param a int32 
-- @param b float 
-- @param c double 
-- @param d vec4 
function ParamRef4Callback(a, b, c, d) end

--- ParamRef5Callback
-- @param a int32 
-- @param b float 
-- @param c double 
-- @param d vec4 
-- @param e int64[] 
function ParamRef5Callback(a, b, c, d, e) end

--- ParamRef6Callback
-- @param a int32 
-- @param b float 
-- @param c double 
-- @param d vec4 
-- @param e int64[] 
-- @param f char8 
function ParamRef6Callback(a, b, c, d, e, f) end

--- ParamRef7Callback
-- @param a int32 
-- @param b float 
-- @param c double 
-- @param d vec4 
-- @param e int64[] 
-- @param f char8 
-- @param g string 
function ParamRef7Callback(a, b, c, d, e, f, g) end

--- ParamRef8Callback
-- @param a int32 
-- @param b float 
-- @param c double 
-- @param d vec4 
-- @param e int64[] 
-- @param f char8 
-- @param g string 
-- @param h char16 
function ParamRef8Callback(a, b, c, d, e, f, g, h) end

--- ParamRef9Callback
-- @param a int32 
-- @param b float 
-- @param c double 
-- @param d vec4 
-- @param e int64[] 
-- @param f char8 
-- @param g string 
-- @param h char16 
-- @param k int16 
function ParamRef9Callback(a, b, c, d, e, f, g, h, k) end

--- ParamRef10Callback
-- @param a int32 
-- @param b float 
-- @param c double 
-- @param d vec4 
-- @param e int64[] 
-- @param f char8 
-- @param g string 
-- @param h char16 
-- @param k int16 
-- @param l ptr64 
function ParamRef10Callback(a, b, c, d, e, f, g, h, k, l) end

--- ParamRefVectorsCallback
-- @param p1 bool[] 
-- @param p2 char8[] 
-- @param p3 char16[] 
-- @param p4 int8[] 
-- @param p5 int16[] 
-- @param p6 int32[] 
-- @param p7 int64[] 
-- @param p8 uint8[] 
-- @param p9 uint16[] 
-- @param p10 uint32[] 
-- @param p11 uint64[] 
-- @param p12 ptr64[] 
-- @param p13 float[] 
-- @param p14 double[] 
-- @param p15 string[] 
function ParamRefVectorsCallback(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15) end

--- ParamAllPrimitivesCallback
-- @param p1 bool 
-- @param p2 char8 
-- @param p3 char16 
-- @param p4 int8 
-- @param p5 int16 
-- @param p6 int32 
-- @param p7 int64 
-- @param p8 uint8 
-- @param p9 uint16 
-- @param p10 uint32 
-- @param p11 uint64 
-- @param p12 ptr64 
-- @param p13 float 
-- @param p14 double 
-- @return int64 
function ParamAllPrimitivesCallback(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14) end

--- ParamAllAliasesCallback
-- @param aBool bool
-- @param aChar8 char8
-- @param aChar16 char16
-- @param aInt8 int8
-- @param aInt16 int16
-- @param aInt32 int32
-- @param aInt64 int64
-- @param aPtr ptr64
-- @param aFloat float
-- @param aDouble double
-- @param aString string
-- @param aAny any
-- @param aVec2 vec2
-- @param aVec3 vec3
-- @param aVec4 vec4
-- @param aMat4x4 mat4x4
-- @param aBoolVec bool[]
-- @param aChar8Vec char8[]
-- @param aChar16Vec char16[]
-- @param aInt8Vec int8[]
-- @param aInt16Vec int16[]
-- @param aInt32Vec int32[]
-- @param aInt64Vec int64[]
-- @param aPtrVec ptr64[]
-- @param aFloatVec float[]
-- @param aDoubleVec double[]
-- @param aStringVec string[]
-- @param aAnyVec any[]
-- @param aVec2Vec vec2[]
-- @param aVec3Vec vec3[]
-- @param aVec4Vec vec4[]
-- @return int32
function ParamAllAliasesCallback(aBool, aChar8, aChar16, aInt8, aInt16, aInt32, aInt64, aPtr, aFloat, aDouble, aString, aAny, aVec2, aVec3, aVec4, aMat4x4, aBoolVec, aChar8Vec, aChar16Vec, aInt8Vec, aInt16Vec, aInt32Vec, aInt64Vec, aPtrVec, aFloatVec, aDoubleVec, aStringVec, aAnyVec, aVec2Vec, aVec3Vec, aVec4Vec) end

--- ParamAllRefAliasesCallback
-- @param aBool bool
-- @param aChar8 char8
-- @param aChar16 char16
-- @param aInt8 int8
-- @param aInt16 int16
-- @param aInt32 int32
-- @param aInt64 int64
-- @param aPtr ptr64
-- @param aFloat float
-- @param aDouble double
-- @param aString string
-- @param aAny any
-- @param aVec2 vec2
-- @param aVec3 vec3
-- @param aVec4 vec4
-- @param aMat4x4 mat4x4
-- @param aBoolVec bool[]
-- @param aChar8Vec char8[]
-- @param aChar16Vec char16[]
-- @param aInt8Vec int8[]
-- @param aInt16Vec int16[]
-- @param aInt32Vec int32[]
-- @param aInt64Vec int64[]
-- @param aPtrVec ptr64[]
-- @param aFloatVec float[]
-- @param aDoubleVec double[]
-- @param aStringVec string[]
-- @param aAnyVec any[]
-- @param aVec2Vec vec2[]
-- @param aVec3Vec vec3[]
-- @param aVec4Vec vec4[]
-- @return int64
function ParamAllRefAliasesCallback(aBool, aChar8, aChar16, aInt8, aInt16, aInt32, aInt64, aPtr, aFloat, aDouble, aString, aAny, aVec2, aVec3, aVec4, aMat4x4, aBoolVec, aChar8Vec, aChar16Vec, aInt8Vec, aInt16Vec, aInt32Vec, aInt64Vec, aPtrVec, aFloatVec, aDoubleVec, aStringVec, aAnyVec, aVec2Vec, aVec3Vec, aVec4Vec) end

--- ParamEnumCallback
-- @param p1 int32
-- @param p2 int32[]
-- @return int32
function ParamEnumCallback(p1, p2) end

--- ParamEnumRefCallback
-- @param p1 int32
-- @param p2 int32[]
-- @return int32
function ParamEnumRefCallback(p1, p2) end

--- ParamVariantCallback
-- @param p1 any
-- @param p2 any[]
function ParamVariantCallback(p1, p2) end

--- ParamVariantRefCallback
-- @param p1 any
-- @param p2 any[]
function ParamVariantRefCallback(p1, p2) end

--- CallFuncVoidCallback
-- @param func function
-- @callback FuncVoid func -
function CallFuncVoidCallback(func) end

--- CallFuncBoolCallback
-- @param func function
-- @return bool
-- @callback FuncBool func -
-- @return bool
function CallFuncBoolCallback(func) end

--- CallFuncChar8Callback
-- @param func function
-- @return char8
-- @callback FuncChar8 func -
-- @return char8
function CallFuncChar8Callback(func) end

--- CallFuncChar16Callback
-- @param func function
-- @return char16
-- @callback FuncChar16 func -
-- @return char16
function CallFuncChar16Callback(func) end

--- CallFuncInt8Callback
-- @param func function
-- @return int8
-- @callback FuncInt8 func -
-- @return int8
function CallFuncInt8Callback(func) end

--- CallFuncInt16Callback
-- @param func function
-- @return int16
-- @callback FuncInt16 func -
-- @return int16
function CallFuncInt16Callback(func) end

--- CallFuncInt32Callback
-- @param func function
-- @return int32
-- @callback FuncInt32 func -
-- @return int32
function CallFuncInt32Callback(func) end

--- CallFuncInt64Callback
-- @param func function
-- @return int64
-- @callback FuncInt64 func -
-- @return int64
function CallFuncInt64Callback(func) end

--- CallFuncUInt8Callback
-- @param func function
-- @return uint8
-- @callback FuncUInt8 func -
-- @return uint8
function CallFuncUInt8Callback(func) end

--- CallFuncUInt16Callback
-- @param func function
-- @return uint16
-- @callback FuncUInt16 func -
-- @return uint16
function CallFuncUInt16Callback(func) end

--- CallFuncUInt32Callback
-- @param func function
-- @return uint32
-- @callback FuncUInt32 func -
-- @return uint32
function CallFuncUInt32Callback(func) end

--- CallFuncUInt64Callback
-- @param func function
-- @return uint64
-- @callback FuncUInt64 func -
-- @return uint64
function CallFuncUInt64Callback(func) end

--- CallFuncPtrCallback
-- @param func function
-- @return ptr64
-- @callback FuncPtr func -
-- @return ptr64
function CallFuncPtrCallback(func) end

--- CallFuncFloatCallback
-- @param func function
-- @return float
-- @callback FuncFloat func -
-- @return float
function CallFuncFloatCallback(func) end

--- CallFuncDoubleCallback
-- @param func function
-- @return double
-- @callback FuncDouble func -
-- @return double
function CallFuncDoubleCallback(func) end

--- CallFuncStringCallback
-- @param func function
-- @return string
-- @callback FuncString func -
-- @return string
function CallFuncStringCallback(func) end

--- CallFuncAnyCallback
-- @param func function
-- @return any
-- @callback FuncAny func -
-- @return any
function CallFuncAnyCallback(func) end

--- CallFuncFunctionCallback
-- @param func function
-- @return ptr64
-- @callback FuncFunction func -
-- @return function
function CallFuncFunctionCallback(func) end

--- CallFuncBoolVectorCallback
-- @param func function
-- @return bool[]
-- @callback FuncBoolVector func -
-- @return bool[]
function CallFuncBoolVectorCallback(func) end

--- CallFuncChar8VectorCallback
-- @param func function
-- @return char8[]
-- @callback FuncChar8Vector func -
-- @return char8[]
function CallFuncChar8VectorCallback(func) end

--- CallFuncChar16VectorCallback
-- @param func function
-- @return char16[]
-- @callback FuncChar16Vector func -
-- @return char16[]
function CallFuncChar16VectorCallback(func) end

--- CallFuncInt8VectorCallback
-- @param func function
-- @return int8[]
-- @callback FuncInt8Vector func -
-- @return int8[]
function CallFuncInt8VectorCallback(func) end

--- CallFuncInt16VectorCallback
-- @param func function
-- @return int16[]
-- @callback FuncInt16Vector func -
-- @return int16[]
function CallFuncInt16VectorCallback(func) end

--- CallFuncInt32VectorCallback
-- @param func function
-- @return int32[]
-- @callback FuncInt32Vector func -
-- @return int32[]
function CallFuncInt32VectorCallback(func) end

--- CallFuncInt64VectorCallback
-- @param func function
-- @return int64[]
-- @callback FuncInt64Vector func -
-- @return int64[]
function CallFuncInt64VectorCallback(func) end

--- CallFuncUInt8VectorCallback
-- @param func function
-- @return uint8[]
-- @callback FuncUInt8Vector func -
-- @return uint8[]
function CallFuncUInt8VectorCallback(func) end

--- CallFuncUInt16VectorCallback
-- @param func function
-- @return uint16[]
-- @callback FuncUInt16Vector func -
-- @return uint16[]
function CallFuncUInt16VectorCallback(func) end

--- CallFuncUInt32VectorCallback
-- @param func function
-- @return uint32[]
-- @callback FuncUInt32Vector func -
-- @return uint32[]
function CallFuncUInt32VectorCallback(func) end

--- CallFuncUInt64VectorCallback
-- @param func function
-- @return uint64[]
-- @callback FuncUInt64Vector func -
-- @return uint64[]
function CallFuncUInt64VectorCallback(func) end

--- CallFuncPtrVectorCallback
-- @param func function
-- @return ptr64[]
-- @callback FuncPtrVector func -
-- @return ptr64[]
function CallFuncPtrVectorCallback(func) end

--- CallFuncFloatVectorCallback
-- @param func function
-- @return float[]
-- @callback FuncFloatVector func -
-- @return float[]
function CallFuncFloatVectorCallback(func) end

--- CallFuncDoubleVectorCallback
-- @param func function
-- @return double[]
-- @callback FuncDoubleVector func -
-- @return double[]
function CallFuncDoubleVectorCallback(func) end

--- CallFuncStringVectorCallback
-- @param func function
-- @return string[]
-- @callback FuncStringVector func -
-- @return string[]
function CallFuncStringVectorCallback(func) end

--- CallFuncAnyVectorCallback
-- @param func function
-- @return any[]
-- @callback FuncAnyVector func -
-- @return any[]
function CallFuncAnyVectorCallback(func) end

--- CallFuncVec2VectorCallback
-- @param func function
-- @return vec2[]
-- @callback FuncVec2Vector func -
-- @return vec2[]
function CallFuncVec2VectorCallback(func) end

--- CallFuncVec3VectorCallback
-- @param func function
-- @return vec3[]
-- @callback FuncVec3Vector func -
-- @return vec3[]
function CallFuncVec3VectorCallback(func) end

--- CallFuncVec4VectorCallback
-- @param func function
-- @return vec4[]
-- @callback FuncVec4Vector func -
-- @return vec4[]
function CallFuncVec4VectorCallback(func) end

--- CallFuncMat4x4VectorCallback
-- @param func function
-- @return mat4x4[]
-- @callback FuncMat4x4Vector func -
-- @return mat4x4[]
function CallFuncMat4x4VectorCallback(func) end

--- CallFuncVec2Callback
-- @param func function
-- @return vec2
-- @callback FuncVec2 func -
-- @return vec2
function CallFuncVec2Callback(func) end

--- CallFuncVec3Callback
-- @param func function
-- @return vec3
-- @callback FuncVec3 func -
-- @return vec3
function CallFuncVec3Callback(func) end

--- CallFuncVec4Callback
-- @param func function
-- @return vec4
-- @callback FuncVec4 func -
-- @return vec4
function CallFuncVec4Callback(func) end

--- CallFuncMat4x4Callback
-- @param func function
-- @return mat4x4
-- @callback FuncMat4x4 func -
-- @return mat4x4
function CallFuncMat4x4Callback(func) end

--- CallFuncAliasBoolCallback
-- @param func function
-- @return bool
-- @callback FuncAliasBool func -
-- @return bool
function CallFuncAliasBoolCallback(func) end

--- CallFuncAliasChar8Callback
-- @param func function
-- @return char8
-- @callback FuncAliasChar8 func -
-- @return char8
function CallFuncAliasChar8Callback(func) end

--- CallFuncAliasChar16Callback
-- @param func function
-- @return char16
-- @callback FuncAliasChar16 func -
-- @return char16
function CallFuncAliasChar16Callback(func) end

--- CallFuncAliasInt8Callback
-- @param func function
-- @return int8
-- @callback FuncAliasInt8 func -
-- @return int8
function CallFuncAliasInt8Callback(func) end

--- CallFuncAliasInt16Callback
-- @param func function
-- @return int16
-- @callback FuncAliasInt16 func -
-- @return int16
function CallFuncAliasInt16Callback(func) end

--- CallFuncAliasInt32Callback
-- @param func function
-- @return int32
-- @callback FuncAliasInt32 func -
-- @return int32
function CallFuncAliasInt32Callback(func) end

--- CallFuncAliasInt64Callback
-- @param func function
-- @return int64
-- @callback FuncAliasInt64 func -
-- @return int64
function CallFuncAliasInt64Callback(func) end

--- CallFuncAliasUInt8Callback
-- @param func function
-- @return uint8
-- @callback FuncAliasUInt8 func -
-- @return uint8
function CallFuncAliasUInt8Callback(func) end

--- CallFuncAliasUInt16Callback
-- @param func function
-- @return uint16
-- @callback FuncAliasUInt16 func -
-- @return uint16
function CallFuncAliasUInt16Callback(func) end

--- CallFuncAliasUInt32Callback
-- @param func function
-- @return uint32
-- @callback FuncAliasUInt32 func -
-- @return uint32
function CallFuncAliasUInt32Callback(func) end

--- CallFuncAliasUInt64Callback
-- @param func function
-- @return uint64
-- @callback FuncAliasUInt64 func -
-- @return uint64
function CallFuncAliasUInt64Callback(func) end

--- CallFuncAliasPtrCallback
-- @param func function
-- @return ptr64
-- @callback FuncAliasPtr func -
-- @return ptr64
function CallFuncAliasPtrCallback(func) end

--- CallFuncAliasFloatCallback
-- @param func function
-- @return float
-- @callback FuncAliasFloat func -
-- @return float
function CallFuncAliasFloatCallback(func) end

--- CallFuncAliasDoubleCallback
-- @param func function
-- @return double
-- @callback FuncAliasDouble func -
-- @return double
function CallFuncAliasDoubleCallback(func) end

--- CallFuncAliasStringCallback
-- @param func function
-- @return string
-- @callback FuncAliasString func -
-- @return string
function CallFuncAliasStringCallback(func) end

--- CallFuncAliasAnyCallback
-- @param func function
-- @return any
-- @callback FuncAliasAny func -
-- @return any
function CallFuncAliasAnyCallback(func) end

--- CallFuncAliasFunctionCallback
-- @param func function
-- @return ptr64
-- @callback FuncAliasFunction func -
-- @return function
function CallFuncAliasFunctionCallback(func) end

--- CallFuncAliasBoolVectorCallback
-- @param func function
-- @return bool[]
-- @callback FuncAliasBoolVector func -
-- @return bool[]
function CallFuncAliasBoolVectorCallback(func) end

--- CallFuncAliasChar8VectorCallback
-- @param func function
-- @return char8[]
-- @callback FuncAliasChar8Vector func -
-- @return char8[]
function CallFuncAliasChar8VectorCallback(func) end

--- CallFuncAliasChar16VectorCallback
-- @param func function
-- @return char16[]
-- @callback FuncAliasChar16Vector func -
-- @return char16[]
function CallFuncAliasChar16VectorCallback(func) end

--- CallFuncAliasInt8VectorCallback
-- @param func function
-- @return int8[]
-- @callback FuncAliasInt8Vector func -
-- @return int8[]
function CallFuncAliasInt8VectorCallback(func) end

--- CallFuncAliasInt16VectorCallback
-- @param func function
-- @return int16[]
-- @callback FuncAliasInt16Vector func -
-- @return int16[]
function CallFuncAliasInt16VectorCallback(func) end

--- CallFuncAliasInt32VectorCallback
-- @param func function
-- @return int32[]
-- @callback FuncAliasInt32Vector func -
-- @return int32[]
function CallFuncAliasInt32VectorCallback(func) end

--- CallFuncAliasInt64VectorCallback
-- @param func function
-- @return int64[]
-- @callback FuncAliasInt64Vector func -
-- @return int64[]
function CallFuncAliasInt64VectorCallback(func) end

--- CallFuncAliasUInt8VectorCallback
-- @param func function
-- @return uint8[]
-- @callback FuncAliasUInt8Vector func -
-- @return uint8[]
function CallFuncAliasUInt8VectorCallback(func) end

--- CallFuncAliasUInt16VectorCallback
-- @param func function
-- @return uint16[]
-- @callback FuncAliasUInt16Vector func -
-- @return uint16[]
function CallFuncAliasUInt16VectorCallback(func) end

--- CallFuncAliasUInt32VectorCallback
-- @param func function
-- @return uint32[]
-- @callback FuncAliasUInt32Vector func -
-- @return uint32[]
function CallFuncAliasUInt32VectorCallback(func) end

--- CallFuncAliasUInt64VectorCallback
-- @param func function
-- @return uint64[]
-- @callback FuncAliasUInt64Vector func -
-- @return uint64[]
function CallFuncAliasUInt64VectorCallback(func) end

--- CallFuncAliasPtrVectorCallback
-- @param func function
-- @return ptr64[]
-- @callback FuncAliasPtrVector func -
-- @return ptr64[]
function CallFuncAliasPtrVectorCallback(func) end

--- CallFuncAliasFloatVectorCallback
-- @param func function
-- @return float[]
-- @callback FuncAliasFloatVector func -
-- @return float[]
function CallFuncAliasFloatVectorCallback(func) end

--- CallFuncAliasDoubleVectorCallback
-- @param func function
-- @return double[]
-- @callback FuncAliasDoubleVector func -
-- @return double[]
function CallFuncAliasDoubleVectorCallback(func) end

--- CallFuncAliasStringVectorCallback
-- @param func function
-- @return string[]
-- @callback FuncAliasStringVector func -
-- @return string[]
function CallFuncAliasStringVectorCallback(func) end

--- CallFuncAliasAnyVectorCallback
-- @param func function
-- @return any[]
-- @callback FuncAliasAnyVector func -
-- @return any[]
function CallFuncAliasAnyVectorCallback(func) end

--- CallFuncAliasVec2VectorCallback
-- @param func function
-- @return vec2[]
-- @callback FuncAliasVec2Vector func -
-- @return vec2[]
function CallFuncAliasVec2VectorCallback(func) end

--- CallFuncAliasVec3VectorCallback
-- @param func function
-- @return vec3[]
-- @callback FuncAliasVec3Vector func -
-- @return vec3[]
function CallFuncAliasVec3VectorCallback(func) end

--- CallFuncAliasVec4VectorCallback
-- @param func function
-- @return vec4[]
-- @callback FuncAliasVec4Vector func -
-- @return vec4[]
function CallFuncAliasVec4VectorCallback(func) end

--- CallFuncAliasMat4x4VectorCallback
-- @param func function
-- @return mat4x4[]
-- @callback FuncAliasMat4x4Vector func -
-- @return mat4x4[]
function CallFuncAliasMat4x4VectorCallback(func) end

--- CallFuncAliasVec2Callback
-- @param func function
-- @return vec2
-- @callback FuncAliasVec2 func -
-- @return vec2
function CallFuncAliasVec2Callback(func) end

--- CallFuncAliasVec3Callback
-- @param func function
-- @return vec3
-- @callback FuncAliasVec3 func -
-- @return vec3
function CallFuncAliasVec3Callback(func) end

--- CallFuncAliasVec4Callback
-- @param func function
-- @return vec4
-- @callback FuncAliasVec4 func -
-- @return vec4
function CallFuncAliasVec4Callback(func) end

--- CallFuncAliasMat4x4Callback
-- @param func function
-- @return mat4x4
-- @callback FuncAliasMat4x4 func -
-- @return mat4x4
function CallFuncAliasMat4x4Callback(func) end

--- CallFuncAliasAllCallback
-- @param func function
-- @return string
-- @callback FuncAliasAll func -
-- @param aBool bool
-- @param aChar8 char8
-- @param aChar16 char16
-- @param aInt8 int8
-- @param aInt16 int16
-- @param aInt32 int32
-- @param aInt64 int64
-- @param aPtr ptr64
-- @param aFloat float
-- @param aDouble double
-- @param aString string
-- @param aAny any
-- @param aVec2 vec2
-- @param aVec3 vec3
-- @param aVec4 vec4
-- @param aMat4x4 mat4x4
-- @param aBoolVec bool[]
-- @param aChar8Vec char8[]
-- @param aChar16Vec char16[]
-- @param aInt8Vec int8[]
-- @param aInt16Vec int16[]
-- @param aInt32Vec int32[]
-- @param aInt64Vec int64[]
-- @param aPtrVec ptr64[]
-- @param aFloatVec float[]
-- @param aDoubleVec double[]
-- @param aStringVec string[]
-- @param aAnyVec any[]
-- @param aVec2Vec vec2[]
-- @param aVec3Vec vec3[]
-- @param aVec4Vec vec4[]
-- @return string
function CallFuncAliasAllCallback(func) end

--- CallFunc1Callback
-- @param func function
-- @return int32
-- @callback Func1 func -
-- @param a vec3
-- @return int32
function CallFunc1Callback(func) end

--- CallFunc2Callback
-- @param func function
-- @return char8
-- @callback Func2 func -
-- @param a float
-- @param b int64
-- @return char8
function CallFunc2Callback(func) end

--- CallFunc3Callback
-- @param func function
-- @callback Func3 func -
-- @param a ptr64
-- @param b vec4
-- @param c string
function CallFunc3Callback(func) end

--- CallFunc4Callback
-- @param func function
-- @return vec4
-- @callback Func4 func -
-- @param a bool
-- @param b int32
-- @param c char16
-- @param d mat4x4
-- @return vec4
function CallFunc4Callback(func) end

--- CallFunc5Callback
-- @param func function
-- @return bool
-- @callback Func5 func -
-- @param a int8
-- @param b vec2
-- @param c ptr64
-- @param d double
-- @param e uint64[]
-- @return bool
function CallFunc5Callback(func) end

--- CallFunc6Callback
-- @param func function
-- @return int64
-- @callback Func6 func -
-- @param a string
-- @param b float
-- @param c float[]
-- @param d int16
-- @param e uint8[]
-- @param f ptr64
-- @return int64
function CallFunc6Callback(func) end

--- CallFunc7Callback
-- @param func function
-- @return double
-- @callback Func7 func -
-- @param vecC char8[]
-- @param u16 uint16
-- @param ch16 char16
-- @param vecU32 uint32[]
-- @param vec4 vec4
-- @param b bool
-- @param u64 uint64
-- @return double
function CallFunc7Callback(func) end

--- CallFunc8Callback
-- @param func function
-- @return mat4x4
-- @callback Func8 func -
-- @param vec3 vec3
-- @param vecU32 uint32[]
-- @param i16 int16
-- @param b bool
-- @param vec4 vec4
-- @param vecC16 char16[]
-- @param ch16 char16
-- @param i32 int32
-- @return mat4x4
function CallFunc8Callback(func) end

--- CallFunc9Callback
-- @param func function
-- @callback Func9 func -
-- @param f float
-- @param vec2 vec2
-- @param vecI8 int8[]
-- @param u64 uint64
-- @param b bool
-- @param str string
-- @param vec4 vec4
-- @param i16 int16
-- @param ptr ptr64
function CallFunc9Callback(func) end

--- CallFunc10Callback
-- @param func function
-- @return uint32
-- @callback Func10 func -
-- @param vec4 vec4
-- @param mat mat4x4
-- @param vecU32 uint32[]
-- @param u64 uint64
-- @param vecC char8[]
-- @param i32 int32
-- @param b bool
-- @param vec2 vec2
-- @param i64 int64
-- @param d double
-- @return uint32
function CallFunc10Callback(func) end

--- CallFunc11Callback
-- @param func function
-- @return ptr64
-- @callback Func11 func -
-- @param vecB bool[]
-- @param ch16 char16
-- @param u8 uint8
-- @param d double
-- @param vec3 vec3
-- @param vecI8 int8[]
-- @param i64 int64
-- @param u16 uint16
-- @param f float
-- @param vec2 vec2
-- @param u32 uint32
-- @return ptr64
function CallFunc11Callback(func) end

--- CallFunc12Callback
-- @param func function
-- @return bool
-- @callback Func12 func -
-- @param ptr ptr64
-- @param vecD double[]
-- @param u32 uint32
-- @param d double
-- @param b bool
-- @param i32 int32
-- @param i8 int8
-- @param u64 uint64
-- @param f float
-- @param vecPtr ptr64[]
-- @param i64 int64
-- @param ch char8
-- @return bool
function CallFunc12Callback(func) end

--- CallFunc13Callback
-- @param func function
-- @return string
-- @callback Func13 func -
-- @param i64 int64
-- @param vecC char8[]
-- @param d uint16
-- @param f float
-- @param b bool[]
-- @param vec4 vec4
-- @param str string
-- @param int32 int32
-- @param vec3 vec3
-- @param ptr ptr64
-- @param vec2 vec2
-- @param arr uint8[]
-- @param i16 int16
-- @return string
function CallFunc13Callback(func) end

--- CallFunc14Callback
-- @param func function
-- @return string[]
-- @callback Func14 func -
-- @param vecC char8[]
-- @param vecU32 uint32[]
-- @param mat mat4x4
-- @param b bool
-- @param ch16 char16
-- @param i32 int32
-- @param vecF float[]
-- @param u16 uint16
-- @param vecU8 uint8[]
-- @param i8 int8
-- @param vec3 vec3
-- @param vec4 vec4
-- @param d double
-- @param ptr ptr64
-- @return string[]
function CallFunc14Callback(func) end

--- CallFunc15Callback
-- @param func function
-- @return int16
-- @callback Func15 func -
-- @param vecI16 int16[]
-- @param mat mat4x4
-- @param vec4 vec4
-- @param ptr ptr64
-- @param u64 uint64
-- @param vecU32 uint32[]
-- @param b bool
-- @param f float
-- @param vecC16 char16[]
-- @param u8 uint8
-- @param i32 int32
-- @param vec2 vec2
-- @param u16 uint16
-- @param d double
-- @param vecU8 uint8[]
-- @return int16
function CallFunc15Callback(func) end

--- CallFunc16Callback
-- @param func function
-- @return ptr64
-- @callback Func16 func -
-- @param vecB bool[]
-- @param i16 int16
-- @param vecI8 int8[]
-- @param vec4 vec4
-- @param mat mat4x4
-- @param vec2 vec2
-- @param vecU64 uint64[]
-- @param vecC char8[]
-- @param str string
-- @param i64 int64
-- @param vecU32 uint32[]
-- @param vec3 vec3
-- @param f float
-- @param d double
-- @param i8 int8
-- @param u16 uint16
-- @return ptr64
function CallFunc16Callback(func) end

--- CallFunc17Callback
-- @param func function
-- @return string
-- @callback Func17 func -
-- @param i32 int32
function CallFunc17Callback(func) end

--- CallFunc18Callback
-- @param func function
-- @return string
-- @callback Func18 func -
-- @param i8 int8
-- @param i16 int16
-- @return vec2
function CallFunc18Callback(func) end

--- CallFunc19Callback
-- @param func function
-- @return string
-- @callback Func19 func -
-- @param u32 uint32
-- @param vec3 vec3
-- @param vecU32 uint32[]
function CallFunc19Callback(func) end

--- CallFunc20Callback
-- @param func function
-- @return string
-- @callback Func20 func -
-- @param ch16 char16
-- @param vec4 vec4
-- @param vecU64 uint64[]
-- @param ch char8
-- @return int32
function CallFunc20Callback(func) end

--- CallFunc21Callback
-- @param func function
-- @return string
-- @callback Func21 func -
-- @param mat mat4x4
-- @param vecI32 int32[]
-- @param vec2 vec2
-- @param b bool
-- @param extraParam double
-- @return float
function CallFunc21Callback(func) end

--- CallFunc22Callback
-- @param func function
-- @return string
-- @callback Func22 func -
-- @param ptr64Ref ptr64
-- @param uint32Ref uint32
-- @param vectorDoubleRef double[]
-- @param int16Ref int16
-- @param plgStringRef string
-- @param plgVector4Ref vec4
-- @return uint64
function CallFunc22Callback(func) end

--- CallFunc23Callback
-- @param func function
-- @return string
-- @callback Func23 func -
-- @param uint64Ref uint64
-- @param plgVector2Ref vec2
-- @param vectorInt16Ref int16[]
-- @param char16Ref char16
-- @param floatRef float
-- @param int8Ref int8
-- @param vectorUInt8Ref uint8[]
function CallFunc23Callback(func) end

--- CallFunc24Callback
-- @param func function
-- @return string
-- @callback Func24 func -
-- @param vectorCharRef char8[]
-- @param int64Ref int64
-- @param vectorUInt8Ref uint8[]
-- @param plgVector4Ref vec4
-- @param uint64Ref uint64
-- @param vectorptr64Ref ptr64[]
-- @param doubleRef double
-- @param vectorptr64Ref2 ptr64[]
-- @return mat4x4
function CallFunc24Callback(func) end

--- CallFunc25Callback
-- @param func function
-- @return string
-- @callback Func25 func -
-- @param int32Ref int32
-- @param vectorptr64Ref ptr64[]
-- @param boolRef bool
-- @param uint8Ref uint8
-- @param plgStringRef string
-- @param plgVector3Ref vec3
-- @param int64Ref int64
-- @param plgVector4Ref vec4
-- @param uint16Ref uint16
-- @return double
function CallFunc25Callback(func) end

--- CallFunc26Callback
-- @param func function
-- @return string
-- @callback Func26 func -
-- @param char16Ref char16
-- @param plgVector2Ref vec2
-- @param plgMatrix4x4Ref mat4x4
-- @param vectorFloatRef float[]
-- @param int16Ref int16
-- @param uint64Ref uint64
-- @param uint32Ref uint32
-- @param vectorUInt16Ref uint16[]
-- @param ptr64Ref ptr64
-- @param boolRef bool
-- @return char8
function CallFunc26Callback(func) end

--- CallFunc27Callback
-- @param func function
-- @return string
-- @callback Func27 func -
-- @param floatRef float
-- @param plgVector3Ref vec3
-- @param ptr64Ref ptr64
-- @param plgVector2Ref vec2
-- @param vectorInt16Ref int16[]
-- @param plgMatrix4x4Ref mat4x4
-- @param boolRef bool
-- @param plgVector4Ref vec4
-- @param int8Ref int8
-- @param int32Ref int32
-- @param vectorUInt8Ref uint8[]
-- @return uint8
function CallFunc27Callback(func) end

--- CallFunc28Callback
-- @param func function
-- @return string
-- @callback Func28 func -
-- @param ptr64Ref ptr64
-- @param uint16Ref uint16
-- @param vectorUInt32Ref uint32[]
-- @param plgMatrix4x4Ref mat4x4
-- @param floatRef float
-- @param plgVector4Ref vec4
-- @param plgStringRef string
-- @param vectorUInt64Ref uint64[]
-- @param int64Ref int64
-- @param boolRef bool
-- @param plgVector3Ref vec3
-- @param vectorFloatRef float[]
-- @return string
function CallFunc28Callback(func) end

--- CallFunc29Callback
-- @param func function
-- @return string
-- @callback Func29 func -
-- @param plgVector4Ref vec4
-- @param int32Ref int32
-- @param vectorInt8Ref int8[]
-- @param doubleRef double
-- @param boolRef bool
-- @param int8Ref int8
-- @param vectorUInt16Ref uint16[]
-- @param floatRef float
-- @param plgStringRef string
-- @param plgMatrix4x4Ref mat4x4
-- @param uint64Ref uint64
-- @param plgVector3Ref vec3
-- @param vectorInt64Ref int64[]
-- @return string[]
function CallFunc29Callback(func) end

--- CallFunc30Callback
-- @param func function
-- @return string
-- @callback Func30 func -
-- @param ptr64Ref ptr64
-- @param plgVector4Ref vec4
-- @param int64Ref int64
-- @param vectorUInt32Ref uint32[]
-- @param boolRef bool
-- @param plgStringRef string
-- @param plgVector3Ref vec3
-- @param vectorUInt8Ref uint8[]
-- @param floatRef float
-- @param plgVector2Ref vec2
-- @param plgMatrix4x4Ref mat4x4
-- @param int8Ref int8
-- @param vectorFloatRef float[]
-- @param doubleRef double
-- @return int32
function CallFunc30Callback(func) end

--- CallFunc31Callback
-- @param func function
-- @return string
-- @callback Func31 func -
-- @param charRef char8
-- @param uint32Ref uint32
-- @param vectorUInt64Ref uint64[]
-- @param plgVector4Ref vec4
-- @param plgStringRef string
-- @param boolRef bool
-- @param int64Ref int64
-- @param vec2Ref vec2
-- @param int8Ref int8
-- @param uint16Ref uint16
-- @param vectorInt16Ref int16[]
-- @param mat4x4Ref mat4x4
-- @param vec3Ref vec3
-- @param floatRef float
-- @param vectorDoubleRef double[]
-- @return vec3
function CallFunc31Callback(func) end

--- CallFunc32Callback
-- @param func function
-- @return string
-- @callback Func32 func -
-- @param p1 int32
-- @param p2 uint16
-- @param p3 int8[]
-- @param p4 vec4
-- @param p5 ptr64
-- @param p6 uint32[]
-- @param p7 mat4x4
-- @param p8 uint64
-- @param p9 string
-- @param p10 int64
-- @param p11 vec2
-- @param p12 int8[]
-- @param p13 bool
-- @param p14 vec3
-- @param p15 uint8
-- @param p16 char16[]
-- @return double
function CallFunc32Callback(func) end

--- CallFunc33Callback
-- @param func function
-- @return string
-- @callback Func33 func -
-- @param variant any
function CallFunc33Callback(func) end

--- CallFuncEnumCallback
-- @param func function
-- @return string
-- @callback FuncEnum func -
-- @param p1 int32
-- @param p2 int32[]
-- @return int32[]
function CallFuncEnumCallback(func) end

--- ResourceHandleCreate
-- @param id int32
-- @param name string
-- @return ptr64
function ResourceHandleCreate(id, name) end

--- ResourceHandleCreateDefault
-- @return ptr64
function ResourceHandleCreateDefault() end

--- ResourceHandleDestroy
-- @param handle ptr64
function ResourceHandleDestroy(handle) end

--- ResourceHandleGetId
-- @param handle ptr64
-- @return int32
function ResourceHandleGetId(handle) end

--- ResourceHandleGetName
-- @param handle ptr64
-- @return string
function ResourceHandleGetName(handle) end

--- ResourceHandleSetName
-- @param handle ptr64
-- @param name string
function ResourceHandleSetName(handle, name) end

--- ResourceHandleIncrementCounter
-- @param handle ptr64
function ResourceHandleIncrementCounter(handle) end

--- ResourceHandleGetCounter
-- @param handle ptr64
-- @return int32
function ResourceHandleGetCounter(handle) end

--- ResourceHandleAddData
-- @param handle ptr64
-- @param value float
function ResourceHandleAddData(handle, value) end

--- ResourceHandleGetData
-- @param handle ptr64
-- @return float[]
function ResourceHandleGetData(handle) end

--- ResourceHandleGetAliveCount
-- @return int32
function ResourceHandleGetAliveCount() end

--- ResourceHandleGetTotalCreated
-- @return int32
function ResourceHandleGetTotalCreated() end

--- ResourceHandleGetTotalDestroyed
-- @return int32
function ResourceHandleGetTotalDestroyed() end

--- CounterCreate
-- @param initialValue int64
-- @return ptr64
function CounterCreate(initialValue) end

--- CounterCreateZero
-- @return ptr64
function CounterCreateZero() end

--- CounterGetValue
-- @param counter ptr64
-- @return int64
function CounterGetValue(counter) end

--- CounterSetValue
-- @param counter ptr64
-- @param value int64
function CounterSetValue(counter, value) end

--- CounterIncrement
-- @param counter ptr64
function CounterIncrement(counter) end

--- CounterDecrement
-- @param counter ptr64
function CounterDecrement(counter) end

--- CounterAdd
-- @param counter ptr64
-- @param amount int64
function CounterAdd(counter, amount) end

--- CounterReset
-- @param counter ptr64
function CounterReset(counter) end

--- CounterIsPositive
-- @param counter ptr64
-- @return bool
function CounterIsPositive(counter) end

--- CounterCompare
-- @param value1 int64
-- @param value2 int64
-- @return int32
function CounterCompare(value1, value2) end

--- CounterSum
-- @param values int64[]
-- @return int64
function CounterSum(values) end

--- RAII wrapper for ResourceHandle pointer
ResourceHandle = {}

--- ResourceHandle
-- @param id int32
-- @param name string
-- @return ResourceHandle
function ResourceHandle.new(id, name) end

--- ResourceHandle
-- @return ResourceHandle
function ResourceHandle.new() end

--- Check if the handle is valid.
-- @return boolean True if the handle is valid, false otherwise
function ResourceHandle:valid() end

--- Get the raw handle value without transferring ownership.
-- @return ptr64 The underlying handle value
function ResourceHandle:get() end

--- Release ownership of the handle and return it.
-- @return ptr64 The released handle value
function ResourceHandle:release() end

--- Reset the handle by closing it.
function ResourceHandle:reset() end

--- Close and destroy the handle if owned.
function ResourceHandle:close() end

--- GetId
-- @return int32
function ResourceHandle:GetId() end

--- GetName
-- @return string
function ResourceHandle:GetName() end

--- SetName
-- @param name string
function ResourceHandle:SetName(name) end

--- IncrementCounter
function ResourceHandle:IncrementCounter() end

--- GetCounter
-- @return int32
function ResourceHandle:GetCounter() end

--- AddData
-- @param value float
function ResourceHandle:AddData(value) end

--- GetData
-- @return float[]
function ResourceHandle:GetData() end

--- GetAliveCount
-- @return int32
function ResourceHandle.GetAliveCount() end

--- GetTotalCreated
-- @return int32
function ResourceHandle.GetTotalCreated() end

--- GetTotalDestroyed
-- @return int32
function ResourceHandle.GetTotalDestroyed() end


--- Class: Counter
Counter = {}

--- Counter
-- @param initialValue int64
-- @return Counter
function Counter.new(initialValue) end

--- Counter
-- @return Counter
function Counter.new() end

--- Check if the handle is valid.
-- @return boolean True if the handle is valid, false otherwise
function Counter:valid() end

--- Get the raw handle value without transferring ownership.
-- @return ptr64 The underlying handle value
function Counter:get() end

--- Release ownership of the handle and return it.
-- @return ptr64 The released handle value
function Counter:release() end

--- Reset the handle by closing it.
function Counter:reset() end

--- GetValue
-- @return int64 
function Counter:GetValue() end

--- SetValue
-- @param value int64 
function Counter:SetValue(value) end

--- Increment
function Counter:Increment() end

--- Decrement
function Counter:Decrement() end

--- Add
-- @param amount int64 
function Counter:Add(amount) end

--- Reset
function Counter:Reset() end

--- IsPositive
-- @return bool 
function Counter:IsPositive() end

--- Compare
-- @param value1 int64 
-- @param value2 int64 
-- @return int32 
function Counter.Compare(value1, value2) end

--- Sum
-- @param values int64[] 
-- @return int64 
function Counter.Sum(values) end



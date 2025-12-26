local master = require 'cross_call_master';
local plugify = require 'plugify'
local Plugin = plugify.Plugin
local Vector2 = plugify.Vector2
local Vector3 = plugify.Vector3
local Vector4 = plugify.Vector4
local Matrix4x4 = plugify.Matrix4x4

local function bool_str(b)
    if type(b) == "boolean" then
        return tostring(b)
    else
        return "<wrong value>"
    end
end

local function ptr_str(v)
    return string.format("0x%x", v)
end

local function ord_zero(ch)
    return utf8.codepoint(ch)
end

local function strip_zero(fl)
    local s = string.format("%f", fl)
    s = s:gsub("%.?0+$", "")
    return s
end

local function float_str(v, aq)
    local format_str = aq and "%.4f" or "%.6f"
    return strip_zero(string.format(format_str, v))
end

local function quote_str(s)
    return "'" .. s .. "'"
end

local function plain_str(s)
    return s
end

local function char8_str(ch)
    return ch
end

local function char16_str(ch)
    return tostring(ord_zero(ch))
end

local function enum_str(ch)
    return tostring(math.floor(tonumber(ch)))
end

local function vector_to_string(array, f)
    f = f or function(v) return tostring(v) end
    local parts = {}
    for i, v in ipairs(array) do
        parts[i] = f(v)
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

-- Assuming Vector2.new, Vector3.new, Vector4.new, and Matrix4x4.new are defined elsewhere
local function pod_to_string(pod)
    if pod.__type == "Vector2" then
        return string.format("{%s, %s}", float_str(pod.x), float_str(pod.y))
    elseif pod.__type == "Vector3" then
        return string.format("{%s, %s, %s}", float_str(pod.x), float_str(pod.y), float_str(pod.z))
    elseif pod.__type == "Vector4" then
        return string.format("{%s, %s, %s, %s}", float_str(pod.x), float_str(pod.y), float_str(pod.z), float_str(pod.w))
    elseif pod.__type == "Matrix4x4" then
        local rows = {}
        for i, row in ipairs(pod.m) do
          local formatted_row = {}
          for j, val in ipairs(row) do
            table.insert(formatted_row, float_str(val))
          end
          table.insert(rows, "{" .. table.concat(formatted_row, ", ") .. "}")
        end
        return "{" .. table.concat(rows, ", ") .. "}"
    else
        error("Non POD type")
    end
end

-- Test part

local CrossCallWorker = {}
setmetatable(CrossCallWorker, { __index = Plugin })

-- Define the plugin_start method
function CrossCallWorker:plugin_start()
    print("CrossCallWorker::plugin_start")
end
--[[
-- Define the plugin_end method
function CrossCallWorker:plugin_end()
    print("CrossCallWorker::plugin_end")
end

-- Define the plugin_update method
function CrossCallWorker:plugin_update(dt)
    print("CrossCallWorker::plugin_update")
end
]]--

local M = {}

M.CrossCallWorker = CrossCallWorker

function M.no_param_return_void()
    -- Does nothing
end

function M.no_param_return_bool()
    return true
end

function M.no_param_return_char8()
    return string.char(0x7f)
end

function M.no_param_return_char16()
    -- Lua strings are 8-bit, so we return the code point
    return utf8.char(0xFFFF)
end

function M.no_param_return_int8()
    return 0x7f
end

function M.no_param_return_int16()
    return 0x7fff
end

function M.no_param_return_int32()
    return 0x7fffffff
end

function M.no_param_return_int64()
    -- Lua 5.3+ has 64-bit integers, otherwise this is a float
    return 0x7fffffffffffffff
end

function M.no_param_return_uint8()
    return 0xff
end

function M.no_param_return_uint16()
    return 0xffff
end

function M.no_param_return_uint32()
    return 0xffffffff
end

function M.no_param_return_uint64()
    return 0xffffffffffffffff
end

function M.no_param_return_pointer()
    return 0x1
end

function M.no_param_return_float()
    return 3.4028235e+38
end

function M.no_param_return_double()
    return 1.7976931348623157e+308  -- Lua numbers are typically doubles
end

function M.no_param_return_function()
    return nil
end

function M.no_param_return_string()
    return "Hello World"
end

function M.no_param_return_any()
    return {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0}
end

function M.no_param_return_array_bool()
    return {true, false}
end

function M.no_param_return_array_char8()
    return {"a", "b", "c", "d"}
end

function M.no_param_return_array_char16()
    return {"a", "b", "c", "d"}
end

function M.no_param_return_array_int8()
    return {-3, -2, -1, 0, 1}
end

function M.no_param_return_array_int16()
    return {-4, -3, -2, -1, 0, 1}
end

function M.no_param_return_array_int32()
    return {-5, -4, -3, -2, -1, 0, 1}
end

function M.no_param_return_array_int64()
    return {-6, -5, -4, -3, -2, -1, 0, 1}
end

function M.no_param_return_array_uint8()
    return {0, 1, 2, 3, 4, 5, 6, 7, 8}
end

function M.no_param_return_array_uint16()
    return {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
end

function M.no_param_return_array_uint32()
    return {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
end

function M.no_param_return_array_uint64()
    return {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
end

function M.no_param_return_array_pointer()
    return {0, 1, 2, 3}
end

function M.no_param_return_array_float()
    return {-12.34, 0.0, 12.34}
end

function M.no_param_return_array_double()
    return {-12.345, 0.0, 12.345}
end

function M.no_param_return_array_string()
    return {
        "1st string", 
        "2nd string", 
        "3rd element string (Should be big enough to avoid small string optimization)"
    }
end

function M.no_param_return_array_any()
    return {
        1.0, 
        2.0, 
        "3rd element string (Should be big enough to avoid small string optimization)", 
        {"lolek", "and", "bolek"}, 
        1
    }
end

-- Assuming Vector2.new, Vector3.new, Vector4.new, and Matrix4x4.new classes are defined elsewhere
function M.no_param_return_array_vector2()
    return {
        Vector2.new(1.1, 2.2),
        Vector2.new(-3.3, 4.4),
        Vector2.new(5.5, -6.6),
        Vector2.new(7.7, 8.8),
        Vector2.new(0.0, 0.0),
    }
end

function M.no_param_return_array_vector3()
    return {
        Vector3.new(1.1, 2.2, 3.3),
        Vector3.new(-4.4, 5.5, -6.6),
        Vector3.new(7.7, 8.8, 9.9),
        Vector3.new(0.0, 0.0, 0.0),
        Vector3.new(10.1, -11.2, 12.3),
    }
end

function M.no_param_return_array_vector4()
    return {
        Vector4.new(1.1, 2.2, 3.3, 4.4),
        Vector4.new(-5.5, 6.6, -7.7, 8.8),
        Vector4.new(9.9, 0.0, -1.1, 2.2),
        Vector4.new(3.3, 4.4, 5.5, 6.6),
        Vector4.new(-7.7, -8.8, 9.9, -10.1),
    }
end

function M.no_param_return_array_matrix4x4()
    return {
        -- Identity matrix
        Matrix4x4.new(),
        -- Example random matrix #1
        Matrix4x4.new({
            {2.0, 3.0, 4.0, 5.0},
            {6.0, 7.0, 8.0, 9.0},
            {10.0, 11.0, 12.0, 13.0},
            {14.0, 15.0, 16.0, 17.0},
        }),
        -- Negative matrix
        Matrix4x4.new({
            {-1.0, -2.0, -3.0, -4.0},
            {-5.0, -6.0, -7.0, -8.0},
            {-9.0, -10.0, -11.0, -12.0},
            {-13.0, -14.0, -15.0, -16.0},
        })
    }
end

function M.no_param_return_vector2()
    return Vector2.new(1.0, 2.0)
end

function M.no_param_return_vector3()
    return Vector3.new(1.0, 2.0, 3.0)
end

function M.no_param_return_vector4()
    return Vector4.new(1.0, 2.0, 3.0, 4.0)
end

function M.no_param_return_matrix4x4()
    return Matrix4x4.new({
        {1.0, 2.0, 3.0, 4.0}, 
        {5.0, 6.0, 7.0, 8.0}, 
        {9.0, 10.0, 11.0, 12.0}, 
        {13.0, 14.0, 15.0, 16.0}
    })
end

function M.param1(a)
    local buffer = tostring(a)
end

function M.param2(a, b)
    local buffer = tostring(a) .. tostring(b)
end

function M.param3(a, b, c)
    local buffer = tostring(a) .. tostring(b) .. tostring(c)
end

function M.param4(a, b, c, d)
    local buffer = tostring(a) .. tostring(b) .. tostring(c) .. tostring(d)
end

function M.param5(a, b, c, d, e)
    local buffer = tostring(a) .. tostring(b) .. tostring(c) .. tostring(d) .. tostring(e)
end

function M.param6(a, b, c, d, e, f)
    local buffer = tostring(a) .. tostring(b) .. tostring(c) .. tostring(d) .. tostring(e) .. tostring(f)
end

function M.param7(a, b, c, d, e, f, g)
    local buffer = tostring(a) .. tostring(b) .. tostring(c) .. tostring(d) .. tostring(e) .. tostring(f) .. tostring(g)
end

function M.param8(a, b, c, d, e, f, g, h)
    local buffer = tostring(a) .. tostring(b) .. tostring(c) .. tostring(d) .. tostring(e) .. tostring(f) .. tostring(g) .. tostring(h)
end

function M.param9(a, b, c, d, e, f, g, h, k)
    local buffer = tostring(a) .. tostring(b) .. tostring(c) .. tostring(d) .. tostring(e) .. tostring(f) .. tostring(g) .. tostring(h) .. tostring(k)
end

function M.param10(a, b, c, d, e, f, g, h, k, l)
    local buffer = tostring(a) .. tostring(b) .. tostring(c) .. tostring(d) .. tostring(e) .. tostring(f) .. tostring(g) .. tostring(h) .. tostring(k) .. tostring(l)
end

function M.param_ref1(a)
    return nil, 42
end

function M.param_ref2(a, b)
    return nil, 10, 3.14
end

function M.param_ref3(a, b, c)
    return nil, -20, 2.718, 3.14159
end

function M.param_ref4(a, b, c, d)
    -- Assuming Vector4.new is defined elsewhere
    return nil, 100, -5.55, 1.618, Vector4.new(1.0, 2.0, 3.0, 4.0)
end

function M.param_ref5(a, b, c, d, e)
    return nil, 500, -10.5, 2.71828, Vector4.new(-1.0, -2.0, -3.0, -4.0), {-6, -5, -4, -3, -2, -1, 0, 1}
end

function M.param_ref6(a, b, c, d, e, f)
    return nil, 750, 20.0, 1.23456, Vector4.new(10.0, 20.0, 30.0, 40.0), {-6, -5, -4}, 'Z'
end

function M.param_ref7(a, b, c, d, e, f, g)
    return nil, -1000, 3.0, -1.0, Vector4.new(100.0, 200.0, 300.0, 400.0), {-6, -5, -4, -3}, 'Y', 'Hello, World!'
end

function M.param_ref8(a, b, c, d, e, f, g, h)
    return nil, 999, -7.5, 0.123456, Vector4.new(-100.0, -200.0, -300.0, -400.0), {-6, -5, -4, -3, -2, -1}, 'X', 'Goodbye, World!', 'A'
end

function M.param_ref9(a, b, c, d, e, f, g, h, k)
    return nil, -1234, 123.45, -678.9, Vector4.new(987.65, 432.1, 123.456, 789.123), 
           {-6, -5, -4, -3, -2, -1, 0, 1, 5, 9}, 'W', 'Testing, 1 2 3', 'B', 42
end

function M.param_ref10(a, b, c, d, e, f, g, h, k, l)
    return nil, 987, -0.123, 456.789, Vector4.new(-123.456, 0.987, 654.321, -789.123), 
           {-6, -5, -4, -3, -2, -1, 0, 1, 5, 9, 4, -7}, 'V', 'Another string', 'C', -444, 0x12345678
end

function M.param_ref_vectors(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15)
    return nil, 
           {true}, 
           {'a', 'b', 'c'}, 
           {'d', 'e', 'f'}, 
           {-3, -2, -1, 0, 1, 2, 3}, 
           {-4, -3, -2, -1, 0, 1, 2, 3, 4}, 
           {-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5}, 
           {-6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6}, 
           {0, 1, 2, 3, 4, 5, 6, 7}, 
           {0, 1, 2, 3, 4, 5, 6, 7, 8}, 
           {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}, 
           {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, 
           {0, 1, 2}, 
           {-12.34, 0.0, 12.34}, 
           {-12.345, 0.0, 12.345}, 
           {'1', '12', '123', '1234', '12345', '123456'}
end

function M.param_all_primitives(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14)
    local buffer = tostring(p1) .. tostring(p2) .. tostring(p3) .. tostring(p4) .. 
                  tostring(p5) .. tostring(p6) .. tostring(p7) .. tostring(p8) .. 
                  tostring(p9) .. tostring(p10) .. tostring(p11) .. tostring(p12) .. 
                  tostring(p13) .. tostring(p14)
    return 56
end

function M.param_enum(p1, p2)
    local sum = 0
    for _, v in ipairs(p2) do
        sum = sum + v
    end
    return p1 + sum
end

function M.param_enum_ref(p1, p2)
    local e = master.Example -- Assuming Example is an object containing enum-like properties
    p1 = e.Forth
    p2 = {e.First, e.Second, e.Third}
    
    local sum = 0
    for _, v in ipairs(p2) do
        sum = sum + v
    end
    return p1 + sum, p1, p2
end

function M.param_variant(p1, p2)
    local buffer = tostring(p1) .. "|" .. tostring(p2)
end

function M.param_variant_ref(p1, p2)
    return nil, 'Z', {false, 6.28, {1.0, 2.0, 3.0}, 0x0, 123456789}
end

function M.call_func_void(func)
    func()
end

function M.call_func_bool(func)
    return func()
end

function M.call_func_char8(func)
    return func()
end

function M.call_func_char16(func)
    return func()
end

function M.call_func_int8(func)
    return func()
end

function M.call_func_int16(func)
    return func()
end

function M.call_func_int32(func)
    return func()
end

function M.call_func_int64(func)
    return func()
end

function M.call_func_uint8(func)
    return func()
end

function M.call_func_uint16(func)
    return func()
end

function M.call_func_uint32(func)
    return func()
end

function M.call_func_uint64(func)
    return func()
end

function M.call_func_ptr(func)
    return func()
end

function M.call_func_float(func)
    return func()
end

function M.call_func_double(func)
    return func()
end

function M.call_func_function(func)
    return func()
end

function M.call_func_string(func)
    return func()
end

function M.call_func_any(func)
    return func()
end

function M.call_func_bool_vector(func)
    return func()
end

function M.call_func_char8_vector(func)
    return func()
end

function M.call_func_char16_vector(func)
    return func()
end

function M.call_func_int8_vector(func)
    return func()
end

function M.call_func_int16_vector(func)
    return func()
end

function M.call_func_int32_vector(func)
    return func()
end

function M.call_func_int64_vector(func)
    return func()
end

function M.call_func_uint8_vector(func)
    return func()
end

function M.call_func_uint16_vector(func)
    return func()
end

function M.call_func_uint32_vector(func)
    return func()
end

function M.call_func_uint64_vector(func)
    return func()
end

function M.call_func_ptr_vector(func)
    return func()
end

function M.call_func_float_vector(func)
    return func()
end

function M.call_func_double_vector(func)
    return func()
end

function M.call_func_string_vector(func)
    return func()
end

function M.call_func_any_vector(func)
    return func()
end

function M.call_func_vec2_vector(func)
    return func()
end

function M.call_func_vec3_vector(func)
    return func()
end

function M.call_func_vec4_vector(func)
    return func()
end

function M.call_func_mat4x4_vector(func)
    return func()
end

function M.call_func_vec2(func)
    return func()
end

function M.call_func_vec3(func)
    return func()
end

function M.call_func_vec4(func)
    return func()
end

function M.call_func_mat4x4(func)
    return func()
end

function M.call_func1(func)
    local vec = Vector3.new(4.5, 5.6, 6.7)
    return func(vec)
end

function M.call_func2(func)
    local f = 2.71
    local i64 = 200
    return func(f, i64)
end

function M.call_func3(func)
    local ptr = 12345
    local vec4 = Vector4.new(7.8, 8.9, 9.1, 10.2)
    local str_value = "RandomString"
    func(ptr, vec4, str_value)
end

function M.call_func4(func)
    local b = false
    local i32 = 42
    local ch16 = "B"
    local mat = Matrix4x4.zero
    return func(b, i32, ch16, mat)
end

function M.call_func5(func)
    local i8 = 10
    local vec2 = Vector2.new(3.4, 5.6)
    local ptr = 67890
    local d = 1.618
    local vec64 = {4, 5, 6}
    return func(i8, vec2, ptr, d, vec64)
end

function M.call_func6(func)
    local str_value = "AnotherString"
    local f = 4.56
    local vec_f = {4.0, 5.0, 6.0}
    local i16 = 30
    local vec_u8 = {3, 4, 5}
    local ptr = 24680
    return func(str_value, f, vec_f, i16, vec_u8, ptr)
end

function M.call_func7(func)
    local vec_c = {"X", "Y", "Z"}
    local u16 = 20
    local ch16 = "C"
    local vec_u32 = {4, 5, 6}
    local vec4 = Vector4.new(4.5, 5.6, 6.7, 7.8)
    local b = false
    local u64 = 200
    return func(vec_c, u16, ch16, vec_u32, vec4, b, u64)
end

function M.call_func8(func)
    local vec3 = Vector3.new(4.0, 5.0, 6.0)
    local vec_u32 = {4, 5, 6}
    local i16 = 30
    local b = false
    local vec4 = Vector4.new(4.5, 5.6, 6.7, 7.8)
    local vec_c16 = {"D", "E"}
    local ch16 = "B"
    local i32 = 50
    return func(vec3, vec_u32, i16, b, vec4, vec_c16, ch16, i32)
end

function M.call_func9(func)
    local f = 2.71
    local vec2 = Vector2.new(3.4, 5.6)
    local vec_i8 = {4, 5, 6}
    local u64 = 250
    local b = false
    local s = "Random"
    local vec4 = Vector4.new(4.5, 5.6, 6.7, 7.8)
    local i16 = 30
    local ptr = 13579
    func(f, vec2, vec_i8, u64, b, s, vec4, i16, ptr)
end

function M.call_func10(func)
    local vec4 = Vector4.new(5.6, 7.8, 8.9, 9.0)
    local mat = Matrix4x4.zero
    local vec_u32 = {4, 5, 6}
    local u64 = 150
    local vec_c = {"X", "Y", "Z"}
    local i32 = 60
    local b = false
    local vec2 = Vector2.new(3.4, 5.6)
    local i64 = 75
    local d = 2.71
    return func(vec4, mat, vec_u32, u64, vec_c, i32, b, vec2, i64, d)
end

function M.call_func11(func)
    local vec_b = {false, true, false}
    local ch16 = "C"
    local u8 = 10
    local d = 2.71
    local vec3 = Vector3.new(4.0, 5.0, 6.0)
    local vec_i8 = {3, 4, 5}
    local i64 = 150
    local u16 = 20
    local f = 2.0
    local vec2 = Vector2.new(4.5, 6.7)
    local u32 = 30
    return func(vec_b, ch16, u8, d, vec3, vec_i8, i64, u16, f, vec2, u32)
end

function M.call_func12(func)
    local ptr = 98765
    local vec_d = {4.0, 5.0, 6.0}
    local u32 = 30
    local d = 1.41
    local b = false
    local i32 = 25
    local i8 = 10
    local u64 = 300
    local f = 2.72
    local vec_ptr = {2, 3, 4}
    local i64 = 200
    local ch = "B"
    return func(ptr, vec_d, u32, d, b, i32, i8, u64, f, vec_ptr, i64, ch)
end

function M.call_func13(func)
    local i64 = 75
    local vec_c = {"D", "E", "F"}
    local u16 = 20
    local f = 2.71
    local vec_b = {false, true, false}
    local vec4 = Vector4.new(5.6, 7.8, 9.0, 10.1)
    local s = "RandomString"
    local i32 = 30
    local vec3 = Vector3.new(4.0, 5.0, 6.0)
    local ptr = 13579
    local vec2 = Vector2.new(4.5, 6.7)
    local vec_u8 = {2, 3, 4}
    local i16 = 20
    return func(i64, vec_c, u16, f, vec_b, vec4, s, i32, vec3, ptr, vec2, vec_u8, i16)
end

function M.call_func14(func)
    local vec_c = {"D", "E", "F"}
    local vec_u32 = {4, 5, 6}
    local mat = Matrix4x4.zero
    local b = false
    local ch16 = "B"
    local i32 = 25
    local vec_f = {4.0, 5.0, 6.0}
    local u16 = 30
    local vec_u8 = {3, 4, 5}
    local i8 = 10
    local vec3 = Vector3.new(4.0, 5.0, 6.0)
    local vec4 = Vector4.new(5.6, 7.8, 9.0, 10.1)
    local d = 2.72
    local ptr = 54321
    return func(vec_c, vec_u32, mat, b, ch16, i32, vec_f, u16, vec_u8, i8, vec3, vec4, d, ptr)
end

function M.call_func15(func)
    local vec_i16 = {4, 5, 6}
    local mat = Matrix4x4.zero
    local vec4 = Vector4.new(7.8, 8.9, 9.0, 10.1)
    local ptr = 12345
    local u64 = 200
    local vec_u32 = {5, 6, 7}
    local b = false
    local f = 3.14
    local vec_c16 = {"D", "E"}
    local u8 = 6
    local i32 = 25
    local vec2 = Vector2.new(5.6, 7.8)
    local u16 = 40
    local d = 2.71
    local vec_u8 = {1, 3, 5}
    return func(vec_i16, mat, vec4, ptr, u64, vec_u32, b, f, vec_c16, u8, i32, vec2, u16, d, vec_u8)
end

function M.call_func16(func)
    local vec_b = {true, true, false}
    local i16 = 20
    local vec_i8 = {2, 3, 4}
    local vec4 = Vector4.new(7.8, 8.9, 9.0, 10.1)
    local mat = Matrix4x4.zero
    local vec2 = Vector2.new(5.6, 7.8)
    local vec_u64 = {5, 6, 7}
    local vec_c = {"D", "E", "F"}
    local s = "DifferentString"
    local i64 = 300
    local vec_u32 = {6, 7, 8}
    local vec3 = Vector3.new(5.0, 6.0, 7.0)
    local f = 3.14
    local d = 2.718
    local i8 = 6
    local u16 = 30
    return func(vec_b, i16, vec_i8, vec4, mat, vec2, vec_u64, vec_c, s, i64, vec_u32, vec3, f, d, i8, u16)
end

function M.call_func17(func)
    local i32 = 42
    _, i32 = func(i32)
    return tostring(i32)
end

function M.call_func18(func)
    local i8, i16 = 9, 25
    local ret
    ret, i8, i16 = func(i8, i16)
    return pod_to_string(ret) .. "|" .. i8 .. "|" .. i16
end

function M.call_func19(func)
    local u32 = 75
    local vec3 = Vector3.new(4.0, 5.0, 6.0)
    local vec_u32 = {4, 5, 6}
    _, u32, vec3, vec_u32 = func(u32, vec3, vec_u32)
    return string.format("%d|%s|%s", u32, pod_to_string(vec3), vector_to_string(vec_u32))
end

function M.call_func20(func)
    local ch16 = "Z"
    local vec4 = Vector4.new(5.0, 6.0, 7.0, 8.0)
    local vec_u64 = {4, 5, 6}
    local ch = "X"
    local ret
    ret, ch16, vec4, vec_u64, ch = func(ch16, vec4, vec_u64, ch)
    return string.format("%s|%s|%s|%s|%s", ret, ord_zero(ch16), pod_to_string(vec4), vector_to_string(vec_u64), ch)
end

function M.call_func21(func)
    local mat = Matrix4x4.zero
    local vec_i32 = {4, 5, 6}
    local vec2 = Vector2.new(3.0, 4.0)
    local b = false
    local d = 6.28
    local ret
    ret, mat, vec_i32, vec2, b, d = func(mat, vec_i32, vec2, b, d)
    return string.format("%s|%s|%s|%s|%s|%s", float_str(ret), pod_to_string(mat), vector_to_string(vec_i32),
                         pod_to_string(vec2), bool_str(b), float_str(d))
end

function M.call_func22(func)
    local ptr, u32, vec_d, i16, str_param = 1, 20, {4.0, 5.0, 6.0}, 15, "Updated Test"
    local vec4 = Vector4.new(5.0, 6.0, 7.0, 8.0)
    local ret
    ret, ptr, u32, vec_d, i16, str_param, vec4 = func(ptr, u32, vec_d, i16, str_param, vec4)
    return string.format("%s|%s|%d|%s|%d|%s|%s", ret, ptr_str(ptr), u32, vector_to_string(vec_d), i16, str_param,
                         pod_to_string(vec4))
end

function M.call_func23(func)
    local u64, vec2, vec_i16, ch16 = 200, Vector2.new(3.0, 4.0), {4, 5, 6}, 'Y'
    local f, i8, vec_u8 = 2.34, 10, {3, 4, 5}
    _, u64, vec2, vec_i16, ch16, f, i8, vec_u8 = func(u64, vec2, vec_i16, ch16, f, i8, vec_u8)
    return string.format("%d|%s|%s|%s|%s|%d|%s", u64, pod_to_string(vec2), vector_to_string(vec_i16), ord_zero(ch16),
                         float_str(f), i8, vector_to_string(vec_u8))
end

function M.call_func24(func)
    local vec_c = {'D', 'E', 'F'}
    local i64, vec_u8 = 100, {3, 4, 5}
    local vec4 = Vector4.new(5.0, 6.0, 7.0, 8.0)
    local u64, vec_ptr = 200, {3, 4, 5}
    local d, vec_ptr_2 = 6.28, {4, 5, 6, 7}
    local ret
    ret, vec_c, i64, vec_u8, vec4, u64, vec_ptr, d, vec_ptr_2 = func(vec_c, i64, vec_u8, vec4, u64, vec_ptr, d, vec_ptr_2)
    return string.format("%s|%s|%d|%s|%s|%d|%s|%s|%s", pod_to_string(ret), vector_to_string(vec_c, char8_str), i64,
                         vector_to_string(vec_u8), pod_to_string(vec4), u64, vector_to_string(vec_ptr, ptr_str),
                         float_str(d), vector_to_string(vec_ptr_2, ptr_str))
end

function M.call_func25(func)
    local i32, vec_ptr, b, u8 = 50, {3, 4, 5}, false, 10
    local str_val = "Updated Test String"
    local vec3, i64 = Vector3.new(4.0, 5.0, 6.0), 100
    local vec4 = Vector4.new(5.0, 6.0, 7.0, 8.0)
    local u16 = 20
    local ret
    ret, i32, vec_ptr, b, u8, str_val, vec3, i64, vec4, u16 = func(i32, vec_ptr, b, u8, str_val, vec3, i64, vec4, u16)
    return string.format("%s|%d|%s|%s|%d|%s|%s|%d|%s|%d", float_str(ret), i32, vector_to_string(vec_ptr, ptr_str),
                         bool_str(b), u8, str_val, pod_to_string(vec3), i64, pod_to_string(vec4), u16)
end

function M.call_func26(func)
    local ch16 = "B"
    local vec2, mat = Vector2.new(3.0, 4.0), Matrix4x4.zero
    local vec_f = {4.0, 5.0, 6.0}
    local i16, u64, u32 = 20, 200, 20
    local vec_u16, ptr, b = {3, 4, 5}, 0xDEADBEAFDEADBEAF, false
    local ret
    ret, ch16, vec2, mat, vec_f, i16, u64, u32, vec_u16, ptr, b = func(ch16, vec2, mat, vec_f, i16, u64, u32, vec_u16, ptr, b)
    return string.format("%s|%s|%s|%s|%s|%d|%d|%s|%s|%s", ret, ord_zero(ch16), pod_to_string(vec2), pod_to_string(mat),
                         vector_to_string(vec_f, float_str), u64, u32, vector_to_string(vec_u16), ptr_str(ptr), bool_str(b))
end

function M.call_func27(func)
    local f, vec3, ptr = 2.56, Vector3.new(4.0, 5.0, 6.0), 0
    local vec2 = Vector2.new(3.0, 4.0)
    local vec_i16, mat, b = {4, 5, 6}, Matrix4x4.zero, false
    local vec4, i8, i32 = Vector4.new(5.0, 6.0, 7.0, 8.0), 10, 40
    local vec_u8 = {3, 4, 5}
    local ret
    ret, f, vec3, ptr, vec2, vec_i16, mat, b, vec4, i8, i32, vec_u8 = func(f, vec3, ptr, vec2, vec_i16, mat, b, vec4, i8, i32, vec_u8)
    return string.format("%s|%s|%s|%s|%s|%s|%s|%s|%s|%d|%d|%s", ret, float_str(f), pod_to_string(vec3), ptr_str(ptr),
                         pod_to_string(vec2), vector_to_string(vec_i16), pod_to_string(mat), bool_str(b),
                         pod_to_string(vec4), i8, i32, vector_to_string(vec_u8))
end

function M.call_func28(func)
    local ptr, u16, vec_u32, mat = 1, 20, {4, 5, 6}, Matrix4x4.zero
    local f = 2.71
    local vec4 = Vector4.new(5.0, 6.0, 7.0, 8.0)
    local str_val = "New example string"
    local vec_u64 = {400, 500, 600}
    local i64, b = 987654321, false
    local vec3, vec_f = Vector3.new(4.0, 5.0, 6.0), {4.0, 5.0, 6.0}
    local ret
    ret, ptr, u16, vec_u32, mat, f, vec4, str_val, vec_u64, i64, b, vec3, vec_f =
        func(ptr, u16, vec_u32, mat, f, vec4, str_val, vec_u64, i64, b, vec3, vec_f)
    return string.format("%s|%s|%d|%s|%s|%s|%s|%s|%s|%d|%s|%s|%s", ret, ptr_str(ptr), u16, vector_to_string(vec_u32),
                         pod_to_string(mat), float_str(f), pod_to_string(vec4), str_val, vector_to_string(vec_u64), i64,
                         bool_str(b), pod_to_string(vec3), vector_to_string(vec_f, float_str))
end

function M.call_func29(func)
    local vec4 = Vector4.new(2.0, 3.0, 4.0, 5.0)
    local i32 = 99
    local vec_i8 = {4, 5, 6}
    local d = 2.71
    local b = false
    local i8 = 10
    local vec_u16 = {4, 5, 6}
    local f = 3.21
    local str_val = "Yet another example string"
    local mat = Matrix4x4.zero
    local u64 = 200
    local vec3 = Vector3.new(5.0, 6.0, 7.0)
    local vec_i64 = {2000, 3000, 4000}

    local ret
    ret, vec4, i32, vec_i8, d, b, i8, vec_u16, f, str_val, mat, u64, vec3, vec_i64 =
        func(vec4, i32, vec_i8, d, b, i8, vec_u16, f, str_val, mat, u64, vec3, vec_i64)

    return string.format("%s|%s|%d|%s|%s|%s|%d|%s|%s|%s|%s|%d|%s|%s",
        vector_to_string(ret, quote_str),
        pod_to_string(vec4), i32,
        vector_to_string(vec_i8),
        float_str(d), bool_str(b),
        i8, vector_to_string(vec_u16),
        float_str(f), str_val,
        pod_to_string(mat), u64,
        pod_to_string(vec3),
        vector_to_string(vec_i64))
end

function M.call_func30(func)
    local ptr = 1
    local vec4 = Vector4.new(2.0, 3.0, 4.0, 5.0)
    local i64 = 987654321
    local vec_u32 = {4, 5, 6}
    local b = false
    local str_val = "Updated String for Func30"
    local vec3 = Vector3.new(5.0, 6.0, 7.0)
    local vec_u8 = {1, 2, 3}
    local f = 5.67
    local vec2 = Vector2.new(3.0, 4.0)
    local mat = Matrix4x4.zero
    local i8 = 10
    local vec_f = {4.0, 5.0, 6.0}
    local d = 8.90

    local ret
    ret, ptr, vec4, i64, vec_u32, b, str_val, vec3, vec_u8, f, vec2, mat, i8, vec_f, d =
        func(ptr, vec4, i64, vec_u32, b, str_val, vec3, vec_u8, f, vec2, mat, i8, vec_f, d)

    return string.format("%s|%s|%s|%d|%s|%s|%s|%s|%s|%s|%s|%s|%d|%s|%s",
        ret, ptr_str(ptr),
        pod_to_string(vec4), i64,
        vector_to_string(vec_u32), bool_str(b),
        str_val, pod_to_string(vec3),
        vector_to_string(vec_u8), float_str(f),
        pod_to_string(vec2), pod_to_string(mat),
        i8, vector_to_string(vec_f, float_str),
        float_str(d, false))
end

function M.call_func31(func)
    local ch = "B"
    local u32 = 200
    local vec_u64 = {4, 5, 6}
    local vec4 = Vector4.new(2.0, 3.0, 4.0, 5.0)
    local str_val = "Updated String for Func31"
    local b = true
    local i64 = 987654321
    local vec2 = Vector2.new(3.0, 4.0)
    local i8 = 10
    local u16 = 20
    local vec_i16 = {4, 5, 6}
    local mat = Matrix4x4.zero
    local vec3 = Vector3.new(4.0, 5.0, 6.0)
    local f = 5.67
    local vec_d = {4.0, 5.0, 6.0}

    local ret
    ret, ch, u32, vec_u64, vec4, str_val, b, i64, vec2, i8, u16, vec_i16, mat, vec3, f, vec_d =
        func(ch, u32, vec_u64, vec4, str_val, b, i64, vec2, i8, u16, vec_i16, mat, vec3, f, vec_d)

    return string.format("%s|%s|%d|%s|%s|%s|%s|%d|%s|%d|%d|%s|%s|%s|%s|%s",
        pod_to_string(ret), ch, u32,
        vector_to_string(vec_u64),
        pod_to_string(vec4), str_val,
        bool_str(b), i64,
        pod_to_string(vec2), i8, u16,
        vector_to_string(vec_i16),
        pod_to_string(mat), pod_to_string(vec3),
        float_str(f), vector_to_string(vec_d))
end

function M.call_func32(func)
    local i32 = 30
    local u16 = 20
    local vec_i8 = {4, 5, 6}
    local vec4 = Vector4.new(2.0, 3.0, 4.0, 5.0)
    local ptr = 1
    local vec_u32 = {4, 5, 6}
    local mat = Matrix4x4.zero
    local u64 = 200
    local str_val = "Updated String for Func32"
    local i64 = 987654321
    local vec2 = Vector2.new(3.0, 4.0)
    local vec_i8_2 = {7, 8, 9}
    local b = false
    local vec3 = Vector3.new(4.0, 5.0, 6.0)
    local u8 = 128
    local vec_c16 = {"D", "E", "F"}

    _, i32, u16, vec_i8, vec4, ptr, vec_u32, mat, u64, str_val, i64, vec2, vec_i8_2, b, vec3, u8, vec_c16 =
        func(i32, u16, vec_i8, vec4, ptr, vec_u32, mat, u64, str_val, i64, vec2, vec_i8_2, b, vec3, u8, vec_c16)

    return string.format("%d|%d|%s|%s|%s|%s|%s|%d|%s|%d|%s|%s|%s|%s|%d|%s",
        i32, u16, vector_to_string(vec_i8),
        pod_to_string(vec4), ptr_str(ptr),
        vector_to_string(vec_u32), pod_to_string(mat),
        u64, str_val, i64,
        pod_to_string(vec2), vector_to_string(vec_i8_2),
        bool_str(b), pod_to_string(vec3),
        u8, vector_to_string(vec_c16, char16_str))
end

function M.call_func33(func)
    local variant = 30
    local _, variant_ref = func(variant)
    return variant_ref
end

function M.call_func_enum(func)
	local e = master.Example
    local val = 0 -- assuming 0 is a valid enum value
    local ret
	ret, val = func(e.Forth, {})
    return vector_to_string(ret, enum_str) .. "|" .. vector_to_string(val, enum_str)
end

function M.reverse_no_param_return_void()
    master:NoParamReturnVoidCallback()
end

function M.reverse_no_param_return_bool()
    local result = master:NoParamReturnBoolCallback()
    return bool_str(result)
end

function M.reverse_no_param_return_char8()
    local result = master:NoParamReturnChar8Callback()
    return char8_str(result)
end

function M.reverse_no_param_return_char16()
    local result = master:NoParamReturnChar16Callback()
    return char16_str(result)
end

function M.reverse_no_param_return_int8()
    local result = master:NoParamReturnInt8Callback()
    return tostring(result)
end

function M.reverse_no_param_return_int16()
    local result = master:NoParamReturnInt16Callback()
    return tostring(result)
end

function M.reverse_no_param_return_int32()
    local result = master:NoParamReturnInt32Callback()
    return tostring(result)
end

function M.reverse_no_param_return_int64()
    local result = master:NoParamReturnInt64Callback()
    return tostring(result)
end

function M.reverse_no_param_return_uint8()
    local result = master:NoParamReturnUInt8Callback()
    return tostring(result)
end

function M.reverse_no_param_return_uint16()
    local result = master:NoParamReturnUInt16Callback()
    return tostring(result)
end

function M.reverse_no_param_return_uint32()
    local result = master:NoParamReturnUInt32Callback()
    return tostring(result)
end

function M.reverse_no_param_return_uint64()
    local result = master:NoParamReturnUInt64Callback()
    return tostring(result)
end

function M.reverse_no_param_return_pointer()
    local result = master:NoParamReturnPointerCallback()
    return ptr_str(result)
end

function M.reverse_no_param_return_float()
    local result = master:NoParamReturnFloatCallback()
    return float_str(result)
end

function M.reverse_no_param_return_double()
    local result = master:NoParamReturnDoubleCallback()
    return tostring(result)
end

function M.reverse_no_param_return_function()
    local result = master:NoParamReturnFunctionCallback()
    return result and tostring(result()) or "<null function pointer>"
end

function M.reverse_no_param_return_string()
    return master:NoParamReturnStringCallback()
end

function M.reverse_no_param_return_any()
    return master:NoParamReturnAnyCallback()
end

function M.reverse_no_param_return_array_bool()
    local result = master:NoParamReturnArrayBoolCallback()
    return vector_to_string(result, bool_str)
end

function M.reverse_no_param_return_array_char8()
    local result = master:NoParamReturnArrayChar8Callback()
    return vector_to_string(result, char8_str)
end

function M.reverse_no_param_return_array_char16()
    local result = master:NoParamReturnArrayChar16Callback()
    return vector_to_string(result, char16_str)
end

function M.reverse_no_param_return_array_int8()
    local result = master:NoParamReturnArrayInt8Callback()
    return vector_to_string(result)
end

function M.reverse_no_param_return_array_int16()
    local result = master:NoParamReturnArrayInt16Callback()
    return vector_to_string(result)
end

function M.reverse_no_param_return_array_int32()
    local result = master:NoParamReturnArrayInt32Callback()
    return vector_to_string(result)
end

function M.reverse_no_param_return_array_int64()
    local result = master:NoParamReturnArrayInt64Callback()
    return vector_to_string(result)
end

function M.reverse_no_param_return_array_uint8()
    local result = master:NoParamReturnArrayUInt8Callback()
    return vector_to_string(result)
end

function M.reverse_no_param_return_array_uint16()
    local result = master:NoParamReturnArrayUInt16Callback()
    return vector_to_string(result)
end

function M.reverse_no_param_return_array_uint32()
    local result = master:NoParamReturnArrayUInt32Callback()
    return vector_to_string(result)
end

function M.reverse_no_param_return_array_uint64()
    local result = master:NoParamReturnArrayUInt64Callback()
    return vector_to_string(result)
end

function M.reverse_no_param_return_array_pointer()
    local result = master:NoParamReturnArrayPointerCallback()
    return vector_to_string(result, ptr_str)
end

function M.reverse_no_param_return_array_float()
    local result = master:NoParamReturnArrayFloatCallback()
    return vector_to_string(result, float_str)
end

function M.reverse_no_param_return_array_double()
    local result = master:NoParamReturnArrayDoubleCallback()
    return vector_to_string(result)
end

function M.reverse_no_param_return_array_string()
    local result = master:NoParamReturnArrayStringCallback()
    return vector_to_string(result, quote_str)
end

function M.reverse_no_param_return_array_any()
    local result = master:NoParamReturnArrayAnyCallback()
    return vector_to_string(result, plain_str)
end

function M.reverse_no_param_return_array_vec2()
    local result = master:NoParamReturnArrayVec2Callback()
    return vector_to_string(result)
end

function M.reverse_no_param_return_array_vec3()
    local result = master:NoParamReturnArrayVec3Callback()
    return vector_to_string(result)
end

function M.reverse_no_param_return_array_vec4()
    local result = master:NoParamReturnArrayVec4Callback()
    return vector_to_string(result)
end

function M.reverse_no_param_return_array_mat4x4()
    local result = master:NoParamReturnArrayMat4x4Callback()
    return vector_to_string(result)
end

function M.reverse_no_param_return_vector2()
    local result = master:NoParamReturnVector2Callback()
    return pod_to_string(result)
end

function M.reverse_no_param_return_vector3()
    local result = master:NoParamReturnVector3Callback()
    return pod_to_string(result)
end

function M.reverse_no_param_return_vector4()
    local result = master:NoParamReturnVector4Callback()
    return pod_to_string(result)
end

function M.reverse_no_param_return_matrix4x4()
    local result = master:NoParamReturnMatrix4x4Callback()
    return pod_to_string(result)
end

function M.reverse_param1()
    master:Param1Callback(999)
end

function M.reverse_param2()
    master:Param2Callback(888, 9.9)
end

function M.reverse_param3()
    master:Param3Callback(777, 8.8, 9.8765)
end

function M.reverse_param4()
    master:Param4Callback(666, 7.7, 8.7659, Vector4.new(100.1, 200.2, 300.3, 400.4))
end

function M.reverse_param5()
    master:Param5Callback(555, 6.6, 7.6598, Vector4.new(-105.1, -205.2, -305.3, -405.4), {})
end

function M.reverse_param6()
    master:Param6Callback(444, 5.5, 6.5987, Vector4.new(110.1, 210.2, 310.3, 410.4), {90000, -100, 20000}, 'A')
end

function M.reverse_param7()
    master:Param7Callback(333, 4.4, 5.9876, Vector4.new(-115.1, -215.2, -315.3, -415.4), {800000, 30000, -4000000}, 'B', 'red gold')
end

function M.reverse_param8()
    master:Param8Callback(222, 3.3, 1.2345, Vector4.new(120.1, 220.2, 320.3, 420.4), {7000000, 5000000, -600000000}, 'C', 'blue ice', 'Z')
end

function M.reverse_param9()
    master:Param9Callback(111, 2.2, 5.1234, Vector4.new(-125.1, -225.2, -325.3, -425.4), {60000000, -700000000, 80000000000}, 'D', 'pink metal', 'Y', -100)
end

function M.reverse_param10()
    master:Param10Callback(1234, 1.1, 4.5123, Vector4.new(130.1, 230.2, 330.3, 430.4), {500000000, 90000000000, 1000000000000}, 'E', 'green wood', 'X', -200, 0xabeba)
end

function M.reverse_param_ref1()
    local _, a = master:ParamRef1Callback(0)
    return tostring(a)
end

function M.reverse_param_ref2()
    local _, a, b = master:ParamRef2Callback(0, 0.0)
    return string.format("%s|%s", a, float_str(b))
end

function M.reverse_param_ref3()
    local _, a, b, c = master:ParamRef3Callback(0, 0.0, 0.0)
    return string.format("%s|%s|%s", a, float_str(b), c)
end

function M.reverse_param_ref4()
    local _, a, b, c, d = master:ParamRef4Callback(0, 0.0, 0.0, Vector4.new())
    return string.format("%s|%s|%s|%s", a, float_str(b), c, pod_to_string(d))
end

function M.reverse_param_ref5()
    local _, a, b, c, d, e = master:ParamRef5Callback(0, 0.0, 0.0, Vector4.new(), {})
    return string.format("%s|%s|%s|%s|%s", a, float_str(b), c, pod_to_string(d), vector_to_string(e))
end

function M.reverse_param_ref6()
    local _, a, b, c, d, e, f = master:ParamRef6Callback(0, 0.0, 0.0, Vector4.new(), {}, '')
    return string.format("%s|%s|%s|%s|%s|%s", a, float_str(b), c, pod_to_string(d), vector_to_string(e), ord_zero(f))
end

function M.reverse_param_ref7()
    local _, a, b, c, d, e, f, g = master:ParamRef7Callback(0, 0.0, 0.0, Vector4.new(), {}, '', '')
    return string.format("%s|%s|%s|%s|%s|%s|%s", a, float_str(b), c, pod_to_string(d), vector_to_string(e), ord_zero(f), g)
end

function M.reverse_param_ref8()
    local _, a, b, c, d, e, f, g, h = master:ParamRef8Callback(0, 0.0, 0.0, Vector4.new(), {}, '', '', '')
    return string.format("%s|%s|%s|%s|%s|%s|%s|%s", a, float_str(b), c, pod_to_string(d), vector_to_string(e), ord_zero(f), g, ord_zero(h))
end

function M.reverse_param_ref9()
    local _, a, b, c, d, e, f, g, h, k = master:ParamRef9Callback(0, 0.0, 0.0, Vector4.new(), {}, '', '', '', 0)
    return string.format("%s|%s|%s|%s|%s|%s|%s|%s|%s", a, float_str(b), c, pod_to_string(d), vector_to_string(e), ord_zero(f), g, ord_zero(h), k)
end

function M.reverse_param_ref10()
    local _, a, b, c, d, e, f, g, h, k, l = master:ParamRef10Callback(0, 0.0, 0.0, Vector4.new(), {}, '', '', '', 0, 0)
    return string.format("%s|%s|%s|%s|%s|%s|%s|%s|%s|%s", a, float_str(b), c, pod_to_string(d), vector_to_string(e), ord_zero(f), g, ord_zero(h), k, ptr_str(l))
end

function M.reverse_param_ref_vectors()
    local _, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15 = master:ParamRefVectorsCallback(
        {true}, {'A'}, {'A'}, {-1}, {-1}, {-1}, {-1}, {0}, {0}, {0}, {0}, {0}, {1.0}, {1.0}, {'Hi'}
    )
    --local p15_formatted = table.concat(table.map(p15, function(v) return string.format("'%s'", v) end), ', ')
    return string.format("%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s",
        vector_to_string(p1, bool_str), vector_to_string(p2, char8_str), vector_to_string(p3, char16_str),
        vector_to_string(p4), vector_to_string(p5), vector_to_string(p6), vector_to_string(p7),
        vector_to_string(p8), vector_to_string(p9), vector_to_string(p10), vector_to_string(p11),
        vector_to_string(p12, ptr_str), vector_to_string(p13, float_str), vector_to_string(p14),
        vector_to_string(p15, quote_str))
end

function M.reverse_param_all_primitives()
    local result = master:ParamAllPrimitivesCallback(true, '%', '☢', -1, -1000, -1000000, -1000000000000,
                                                    200, 50000, 3000000000, 9999999999, 0xfedcbaabcdef,
                                                    0.001, 987654.456789)
    return tostring(result)
end

function M.reverse_param_enum()
    local e = master.Example
    local result = master:ParamEnumCallback(e.Forth, {e.First, e.Second, e.Third})
    return tostring(result)
end

function M.reverse_param_enum_ref()
    local e = master.Example
    local result, p1, p2 = master:ParamEnumRefCallback(e.First, {e.First, e.First, e.Second})
    return string.format("%s|%s|%s", result, enum_str(p1), vector_to_string(p2, enum_str))
end

function M.reverse_param_variant()
    local p1 = 'my custom string with enough chars'
    local p2 = {'X', '☢', -1, -1000, -1000000, -1000000000000, 200, 50000, 3000000000, 9999999999,
                0xfedcbaabcdef, 0.001, 987654.456789}
    master:ParamVariantCallback(p1, p2)
end

function M.reverse_param_variant_ref()
    local _, p1, p2 = master:ParamVariantRefCallback('my custom string with enough chars',
        {'X', '☢', -1, -1000, -1000000, -1000000000000, 200, 50000, 3000000000, 9999999999,
         0xfedcbaabcdef, 0.001, 987654.456789})
    return string.format("%s|{%s, %s, %s}", vector_to_string(p1), bool_str(p2[1]), float_str(p2[2]), p2[3])
end

local CallbackHolder = {}

function CallbackHolder.mock_void()
    -- No-op, equivalent to Python's pass
end

function CallbackHolder.mock_bool()
    return true
end

function CallbackHolder.mock_char8()
    return 'A'
end

function CallbackHolder.mock_char16()
    return 'Z'
end

function CallbackHolder.mock_int8()
    return 10
end

function CallbackHolder.mock_int16()
    return 100
end

function CallbackHolder.mock_int32()
    return 1000
end

function CallbackHolder.mock_int64()
    return 10000
end

function CallbackHolder.mock_uint8()
    return 20
end

function CallbackHolder.mock_uint16()
    return 200
end

function CallbackHolder.mock_uint32()
    return 2000
end

function CallbackHolder.mock_uint64()
    return 20000
end

function CallbackHolder.mock_ptr()
    return 0
end

function CallbackHolder.mock_float()
    return 3.14
end

function CallbackHolder.mock_double()
    return 6.28
end

function CallbackHolder.mock_function()
    return 2
end

function CallbackHolder.mock_string()
    return 'Test string'
end

function CallbackHolder.mock_any()
    return 'A'
end

function CallbackHolder.mock_bool_array()
    return {true, false}
end

function CallbackHolder.mock_char8_array()
    return {'A', 'B'}
end

function CallbackHolder.mock_char16_array()
    return {'A', 'B'}
end

function CallbackHolder.mock_int8_array()
    return {10, 20}
end

function CallbackHolder.mock_int16_array()
    return {100, 200}
end

function CallbackHolder.mock_int32_array()
    return {1000, 2000}
end

function CallbackHolder.mock_int64_array()
    return {10000, 20000}
end

function CallbackHolder.mock_uint8_array()
    return {20, 30}
end

function CallbackHolder.mock_uint16_array()
    return {200, 300}
end

function CallbackHolder.mock_uint32_array()
    return {2000, 3000}
end

function CallbackHolder.mock_uint64_array()
    return {20000, 30000}
end

function CallbackHolder.mock_ptr_array()
    return {0, 1}
end

function CallbackHolder.mock_float_array()
    return {1.1, 2.2}
end

function CallbackHolder.mock_double_array()
    return {3.3, 4.4}
end

function CallbackHolder.mock_string_array()
    return {'Hello', 'World'}
end

function CallbackHolder.mock_any_array()
    return {'Hello', 3.14, 6.28, 1, 0xdeadbeaf}
end

function CallbackHolder.mock_vec2_array()
    return {
        Vector2.new(0.5, -1.2),
        Vector2.new(3.4, 7.8),
        Vector2.new(-6.7, 2.3),
        Vector2.new(8.9, -4.5),
        Vector2.new(0.0, 0.0)
    }
end

function CallbackHolder.mock_vec3_array()
    return {
        Vector3.new(2.1, 3.2, 4.3),
        Vector3.new(-5.4, 6.5, -7.6),
        Vector3.new(8.7, 9.8, 0.1),
        Vector3.new(1.2, -3.3, 4.4),
        Vector3.new(-5.5, 6.6, -7.7)
    }
end

function CallbackHolder.mock_vec4_array()
    return {
        Vector4.new(0.1, 1.2, 2.3, 3.4),
        Vector4.new(-4.5, 5.6, 6.7, -7.8),
        Vector4.new(8.9, -9.0, 10.1, -11.2),
        Vector4.new(12.3, 13.4, 14.5, 15.6),
        Vector4.new(-16.7, 17.8, 18.9, -19.0)
    }
end

function CallbackHolder.mock_mat4x4_array()
    return {
        -- Identity matrix
        Matrix4x4.new(),
        -- Random matrix #1
        Matrix4x4.new({
            {0.5, 1.0, 1.5, 2.0},
            {2.5, 3.0, 3.5, 4.0},
            {4.5, 5.0, 5.5, 6.0},
            {6.5, 7.0, 7.5, 8.0}
        }),
        -- Random matrix #2
        Matrix4x4.new({
            {-1.0, -2.0, -3.0, -4.0},
            {-5.0, -6.0, -7.0, -8.0},
            {-9.0, -10.0, -11.0, -12.0},
            {-13.0, -14.0, -15.0, -16.0}
        }),
        -- Random matrix #3
        Matrix4x4.new({
            {1.1, 2.2, 3.3, 4.4},
            {5.5, 6.6, 7.7, 8.8},
            {9.9, 10.0, 11.1, 12.2},
            {13.3, 14.4, 15.5, 16.6}
        })
    }
end

function CallbackHolder.mock_vec2()
    return Vector2.new(1.0, 2.0)
end

function CallbackHolder.mock_vec3()
    return Vector3.new(1.0, 2.0, 3.0)
end

function CallbackHolder.mock_vec4()
    return Vector4.new(1.0, 2.0, 3.0, 4.0)
end

function CallbackHolder.mock_mat4x4()
    local mat = Matrix4x4.new(
		1, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0
	)
    return mat
end

function CallbackHolder.mock_func1(vec3)
    return math.floor(vec3.x + vec3.y + vec3.z)
end

function CallbackHolder.mock_func2(a, b)
    return '&'
end

function CallbackHolder.mock_func3(p, v, s)
    -- No-op
end

function CallbackHolder.mock_func4(flag, u, c, m)
    return Vector4.new(1.0, 2.0, 3.0, 4.0)
end

function CallbackHolder.mock_func5(i, v, p, d, vec)
    return true
end

function CallbackHolder.mock_func6(s, f, vec, i, u_vec, p)
    return math.floor(f + i)
end

function CallbackHolder.mock_func7(vec, u, c, u_vec, v, flag, l)
    return 3.14
end

function CallbackHolder.mock_func8(v, u_vec, i, flag, v4, c_vec, c, a)
    return Matrix4x4.zero
end

function CallbackHolder.mock_func9(f, v, i_vec, l, flag, s, v4, i, p)
    -- No-op
end

function CallbackHolder.mock_func10(v4, m, u_vec, l, c_vec, a, flag, v, i, d)
    return 42
end

function CallbackHolder.mock_func11(b_vec, c, u, d, v3, i_vec, i, u16, f, v, u32)
    return 0
end

function CallbackHolder.mock_func12(p, d_vec, u, d, flag, a, i, l, f, p_vec, i64, c)
    return false
end

function CallbackHolder.mock_func13(i64, c_vec, u16, f, b_vec, v4, s, a, v3, p, v2, u8_vec, i16)
    return 'Dummy String'
end

function CallbackHolder.mock_func14(c_vec, u_vec, m, flag, c, a, f_vec, u16, u8_vec, i8, v3, v4, d, p)
    return {'String1', 'String2'}
end

function CallbackHolder.mock_func15(i_vec, m, v4, p, l, u_vec, flag, f, c_vec, u, a, v2, u16, d, u8_vec)
    return 257
end

function CallbackHolder.mock_func16(b_vec, i16, i_vec, v4, m, v2, u_vec, c_vec, s, i64, u32_vec, v3, f, d, i8, u16)
    return 0
end

function CallbackHolder.mock_func17(ref_val)
    ref_val = ref_val + 10
    return nil, ref_val
end

function CallbackHolder.mock_func18(i8, i16)
    i8 = 5
    i16 = 10
    return Vector2.new(5.0, 10.0), i8, i16
end

function CallbackHolder.mock_func19(u32, v3, u_vec)
    u32 = 42
    v3 = Vector3.new(1.0, 2.0, 3.0)
    u_vec = {1, 2, 3}
    return nil, u32, v3, u_vec
end

function CallbackHolder.mock_func20(c, v4, u_vec, ch)
    c = 't'
    v4 = Vector4.new(1.0, 2.0, 3.0, 4.0)
    u_vec = {100, 200}
    ch = 'F'
    return 0, c, v4, u_vec, ch
end

function CallbackHolder.mock_func21(m, i_vec, v2, flag, d)
    flag = true
    d = 3.14
    v2 = Vector2.new(1.0, 2.0)
    m = Matrix4x4.new({
        {1.3, 0.6, 0.8, 0.5},
        {0.7, 1.1, 0.2, 0.4},
        {0.9, 0.3, 1.2, 0.7},
        {0.2, 0.8, 0.5, 1.0}
    })
    i_vec = {1, 2, 3}
    return 0.0, m, i_vec, v2, flag, d
end

function CallbackHolder.mock_func22(p, u32, d_vec, i16, s, v4)
    p = 0
    u32 = 99
    i16 = 123
    s = 'Hello'
    v4 = Vector4.new(1.0, 2.0, 3.0, 4.0)
    d_vec = {1.1, 2.2, 3.3}
    return 0, p, u32, d_vec, i16, s, v4
end

function CallbackHolder.mock_func23(u64, v2, i_vec, c, f, i8, u8_vec)
    u64 = 50
    f = 1.5
    i8 = -1
    v2 = Vector2.new(3.0, 4.0)
    u8_vec = {1, 2, 3}
    c = 'Ⅴ'
    i_vec = {1, 2, 3, 4}
    return 5, u64, v2, i_vec, c, f, i8, u8_vec
end

function CallbackHolder.mock_func24(c_vec, i64, u8_vec, v4, u64, p_vec, d, v_vec)
    i64 = 64
    d = 2.71
    v4 = Vector4.new(1.0, 2.0, 3.0, 4.0)
    c_vec = {'a', 'b', 'c'}
    u8_vec = {5, 6, 7}
    p_vec = {0}
    v_vec = {1, 1, 2, 2}
    u64 = 0xffffffff
    return Matrix4x4.zero, c_vec, i64, u8_vec, v4, u64, p_vec, d, v_vec
end

function CallbackHolder.mock_func25(i32, p_vec, flag, u8, s, v3, i64, v4, u16)
    flag = false
    i32 = 100
    u8 = 250
    v3 = Vector3.new(1.0, 2.0, 3.0)
    v4 = Vector4.new(4.0, 5.0, 6.0, 7.0)
    s = 'MockFunc25'
    p_vec = {0}
    i64 = 1337
    u16 = 64222
    return 0.0, i32, p_vec, flag, u8, s, v3, i64, v4, u16
end

function CallbackHolder.mock_func26(c, v2, m, f_vec, i16, u64, u32, u16_vec, p, flag)
    c = 'Z'
    flag = true
    v2 = Vector2.new(2.0, 3.0)
    m = Matrix4x4.new({
        {0.9, 0.2, 0.4, 0.8},
        {0.1, 1.0, 0.6, 0.3},
        {0.7, 0.5, 0.2, 0.9},
        {0.3, 0.4, 1.5, 0.1}
    })
    f_vec = {1.1, 2.2}
    u64 = 64
    u32 = 32
    u16_vec = {100, 200}
    i16 = 332
    p = 0xDEADBEAFDEADBEAF
    return 'A', c, v2, m, f_vec, i16, u64, u32, u16_vec, p, flag
end

function CallbackHolder.mock_func27(f, v3, p, v2, i16_vec, m, flag, v4, i8, i32, u8_vec)
    f = 1.0
    v3 = Vector3.new(-1.0, -2.0, -3.0)
    p = 0xDEADBEAFDEADBEAF
    v2 = Vector2.new(-111.0, 111.0)
    i16_vec = {1, 2, 3, 4}
    m = Matrix4x4.new({
        {1.0, 0.5, 0.3, 0.7},
        {0.8, 1.2, 0.6, 0.9},
        {1.5, 1.1, 0.4, 0.2},
        {0.3, 0.9, 0.7, 1.0}
    })
    flag = true
    v4 = Vector4.new(1.0, 2.0, 3.0, 4.0)
    i8 = 111
    i32 = 30
    u8_vec = {0, 0, 0, 0, 0, 0, 1, 0}
    return 0, f, v3, p, v2, i16_vec, m, flag, v4, i8, i32, u8_vec
end

function CallbackHolder.mock_func28(ptr, u16, u32_vec, m, f, v4, s, u64_vec, i64, b, vec3, f_vec)
    ptr = 0
    u16 = 65500
    u32_vec = {1, 2, 3, 4, 5, 7}
    m = Matrix4x4.new({
        {1.4, 0.7, 0.2, 0.5},
        {0.3, 1.1, 0.6, 0.8},
        {0.9, 0.4, 1.3, 0.1},
        {0.6, 0.2, 0.7, 1.0}
    })
    f = 5.5
    v4 = Vector4.new(1.0, 2.0, 3.0, 4.0)
    s = 'MockFunc28'
    u64_vec = {1, 2}
    i64 = 834748377834
    b = true
    vec3 = Vector3.new(10.0, 20.0, 30.0)
    f_vec = {1.0, -1000.0, 2000.0}
    return s, ptr, u16, u32_vec, m, f, v4, s, u64_vec, i64, b, vec3, f_vec
end

function CallbackHolder.mock_func29(v4, i32, i_vec, d, flag, i8, u16_vec, f, s, m, u64, v3, i64_vec)
    i32 = 30
    flag = true
    v4 = Vector4.new(1.0, 2.0, 3.0, 4.0)
    d = 3.14
    i8 = 8
    u16_vec = {100, 200}
    f = 1.5
    s = 'MockFunc29'
    m = Matrix4x4.new({
        {0.4, 1.0, 0.6, 0.3},
        {1.2, 0.8, 0.5, 0.9},
        {0.7, 0.3, 1.4, 0.6},
        {0.1, 0.9, 0.8, 1.3}
    })
    u64 = 64
    v3 = Vector3.new(1.0, 2.0, 3.0)
    i64_vec = {1, 2, 3}
    i_vec = {127, 126, 125}
    return {'Example', 'MockFunc29'}, v4, i32, i_vec, d, flag, i8, u16_vec, f, s, m, u64, v3, i64_vec
end

function CallbackHolder.mock_func30(p, v4, i64, u_vec, flag, s, v3, u8_vec, f, v2, m, i8, v_vec, d)
    flag = false
    f = 1.1
    i64 = 1000
    v2 = Vector2.new(3.0, 4.0)
    v4 = Vector4.new(1.0, 2.0, 3.0, 4.0)
    s = 'MockFunc30'
    p = 0
    u_vec = {100, 200}
    m = Matrix4x4.new({
        {0.5, 0.3, 1.0, 0.7},
        {1.1, 0.9, 0.6, 0.4},
        {0.2, 0.8, 1.5, 0.3},
        {0.7, 0.4, 0.9, 1.0}
    })
    i8 = 8
    v_vec = {1.0, 1.0, 2.0, 2.0}
    d = 2.718
    v3 = Vector3.new(1.0, 2.0, 3.0)
    u8_vec = {255, 0, 255, 200, 100, 200}
    return 42, p, v4, i64, u_vec, flag, s, v3, u8_vec, f, v2, m, i8, v_vec, d
end

function CallbackHolder.mock_func31(c, u32, u_vec, v4, s, flag, i64, v2, i8, u16, i_vec, m, v3, f, v4_vec)
    u32 = 12345
    flag = true
    v3 = Vector3.new(1.0, 2.0, 3.0)
    s = 'MockFunc31'
    v2 = Vector2.new(5.0, 6.0)
    i8 = 7
    u16 = 255
    m = Matrix4x4.new({
        {0.8, 0.5, 1.2, 0.3},
        {1.0, 0.7, 0.4, 0.6},
        {0.9, 0.2, 0.5, 1.4},
        {0.6, 0.8, 1.1, 0.7}
    })
    i_vec = {1, 2}
    v4 = Vector4.new(1.0, 2.0, 3.0, 4.0)
    i64 = 123456789
    c = 'C'
    v4_vec = {1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 2.0}
    u_vec = {1, 2, 3, 4, 5}
    f = -1.0
    return Vector3.new(1.0, 2.0, 3.0), c, u32, u_vec, v4, s, flag, i64, v2, i8, u16, i_vec, m, v3, f, v4_vec
end

function CallbackHolder.mock_func32(i32, u16, i_vec, v4, p, u_vec, m, u64, s, i64, v2, u8_vec, flag, v3, u8, c_vec)
    i32 = 42
    u16 = 255
    flag = false
    v2 = Vector2.new(2.5, 3.5)
    u8_vec = {1, 2, 3, 4, 5, 9}
    v4 = Vector4.new(4.0, 5.0, 6.0, 7.0)
    s = 'MockFunc32'
    p = 0
    m = Matrix4x4.new({
        {1.0, 0.4, 0.3, 0.9},
        {0.7, 1.2, 0.5, 0.8},
        {0.2, 0.6, 1.1, 0.4},
        {0.9, 0.3, 0.8, 1.5}
    })
    u64 = 123456789
    u_vec = {100, 200}
    i64 = 1000
    v3 = Vector3.new(0.0, 0.0, 0.0)
    u8 = 8
    c_vec = {'a', 'b', 'c'}
    i_vec = {0, 1}
    return 1.0, i32, u16, i_vec, v4, p, u_vec, m, u64, s, i64, v2, u8_vec, flag, v3, u8, c_vec
end

function CallbackHolder.mock_func33(variant)
    variant = 'MockFunc33'
    return nil, variant
end

function CallbackHolder.mock_func_enum(p1, p2)
    local e = master.Example
    p2 = {e.First, e.Second, e.Third}
    return {p1, e.Forth}, p2
end

function M.reverse_call_func_void()
    master:CallFuncVoidCallback(CallbackHolder.mock_void)
    return ''
end

function M.reverse_call_func_bool()
    local result = master:CallFuncBoolCallback(CallbackHolder.mock_bool)
    return bool_str(result)
end

function M.reverse_call_func_char8()
    local result = master:CallFuncChar8Callback(CallbackHolder.mock_char8)
    return string.format('%s', ord_zero(result))
end

function M.reverse_call_func_char16()
    local result = master:CallFuncChar16Callback(CallbackHolder.mock_char16)
    return string.format('%s', ord_zero(result))
end

function M.reverse_call_func_int8()
    local result = master:CallFuncInt8Callback(CallbackHolder.mock_int8)
    return tostring(result)
end

function M.reverse_call_func_int16()
    local result = master:CallFuncInt16Callback(CallbackHolder.mock_int16)
    return tostring(result)
end

function M.reverse_call_func_int32()
    local result = master:CallFuncInt32Callback(CallbackHolder.mock_int32)
    return tostring(result)
end

function M.reverse_call_func_int64()
    local result = master:CallFuncInt64Callback(CallbackHolder.mock_int64)
    return tostring(result)
end

function M.reverse_call_func_uint8()
    local result = master:CallFuncUInt8Callback(CallbackHolder.mock_uint8)
    return tostring(result)
end

function M.reverse_call_func_uint16()
    local result = master:CallFuncUInt16Callback(CallbackHolder.mock_uint16)
    return tostring(result)
end

function M.reverse_call_func_uint32()
    local result = master:CallFuncUInt32Callback(CallbackHolder.mock_uint32)
    return tostring(result)
end

function M.reverse_call_func_uint64()
    local result = master:CallFuncUInt64Callback(CallbackHolder.mock_uint64)
    return tostring(result)
end

function M.reverse_call_func_ptr()
    local result = master:CallFuncPtrCallback(CallbackHolder.mock_ptr)
    return ptr_str(result)
end

function M.reverse_call_func_float()
    local result = master:CallFuncFloatCallback(CallbackHolder.mock_float)
    return float_str(result)
end

function M.reverse_call_func_double()
    local result = master:CallFuncDoubleCallback(CallbackHolder.mock_double)
    return tostring(result)
end

function M.reverse_call_func_string()
    local result = master:CallFuncStringCallback(CallbackHolder.mock_string)
    return result
end

function M.reverse_call_func_any()
    local result = master:CallFuncAnyCallback(CallbackHolder.mock_any)
    return result
end

function M.reverse_call_func_bool_vector()
    local result = master:CallFuncBoolVectorCallback(CallbackHolder.mock_bool_array)
    return vector_to_string(result, bool_str)
end

function M.reverse_call_func_char8_vector()
    local result = master:CallFuncChar8VectorCallback(CallbackHolder.mock_char8_array)
    return vector_to_string(result, char8_str)
end

function M.reverse_call_func_char16_vector()
    local result = master:CallFuncChar16VectorCallback(CallbackHolder.mock_char16_array)
    return vector_to_string(result, char16_str)
end

function M.reverse_call_func_int8_vector()
    local result = master:CallFuncInt8VectorCallback(CallbackHolder.mock_int8_array)
    return vector_to_string(result)
end

function M.reverse_call_func_int16_vector()
    local result = master:CallFuncInt16VectorCallback(CallbackHolder.mock_int16_array)
    return vector_to_string(result)
end

function M.reverse_call_func_int32_vector()
    local result = master:CallFuncInt32VectorCallback(CallbackHolder.mock_int32_array)
    return vector_to_string(result)
end

function M.reverse_call_func_int64_vector()
    local result = master:CallFuncInt64VectorCallback(CallbackHolder.mock_int64_array)
    return vector_to_string(result)
end

function M.reverse_call_func_uint8_vector()
    local result = master:CallFuncUInt8VectorCallback(CallbackHolder.mock_uint8_array)
    return vector_to_string(result)
end

function M.reverse_call_func_uint16_vector()
    local result = master:CallFuncUInt16VectorCallback(CallbackHolder.mock_uint16_array)
    return vector_to_string(result)
end

function M.reverse_call_func_uint32_vector()
    local result = master:CallFuncUInt32VectorCallback(CallbackHolder.mock_uint32_array)
    return vector_to_string(result)
end

function M.reverse_call_func_uint64_vector()
    local result = master:CallFuncUInt64VectorCallback(CallbackHolder.mock_uint64_array)
    return vector_to_string(result)
end

function M.reverse_call_func_ptr_vector()
    local result = master:CallFuncPtrVectorCallback(CallbackHolder.mock_ptr_array)
    return vector_to_string(result, ptr_str)
end

function M.reverse_call_func_float_vector()
    local result = master:CallFuncFloatVectorCallback(CallbackHolder.mock_float_array)
    return vector_to_string(result, float_str)
end

function M.reverse_call_func_double_vector()
    local result = master:CallFuncDoubleVectorCallback(CallbackHolder.mock_double_array)
    return vector_to_string(result)
end

function M.reverse_call_func_string_vector()
    local result = master:CallFuncStringVectorCallback(CallbackHolder.mock_string_array)
    return vector_to_string(result, quote_str)
end

function M.reverse_call_func_any_vector()
    local result = master:CallFuncAnyVectorCallback(CallbackHolder.mock_any_array)
    return vector_to_string(result, plain_str)
end

function M.reverse_call_func_vec2_vector()
    local result = master:CallFuncVec2VectorCallback(CallbackHolder.mock_vec2_array)
    return vector_to_string(result, pod_to_string)
end

function M.reverse_call_func_vec3_vector()
    local result = master:CallFuncVec3VectorCallback(CallbackHolder.mock_vec3_array)
    return vector_to_string(result, pod_to_string)
end

function M.reverse_call_func_vec4_vector()
    local result = master:CallFuncVec4VectorCallback(CallbackHolder.mock_vec4_array)
    return vector_to_string(result, pod_to_string)
end

function M.reverse_call_func_mat4x4_vector()
    local result = master:CallFuncMat4x4VectorCallback(CallbackHolder.mock_mat4x4_array)
    return vector_to_string(result, pod_to_string)
end

function M.reverse_call_func_vec2()
    local result = master:CallFuncVec2Callback(CallbackHolder.mock_vec2)
    return pod_to_string(result)
end

function M.reverse_call_func_vec3()
    local result = master:CallFuncVec3Callback(CallbackHolder.mock_vec3)
    return pod_to_string(result)
end

function M.reverse_call_func_vec4()
    local result = master:CallFuncVec4Callback(CallbackHolder.mock_vec4)
    return pod_to_string(result)
end

function M.reverse_call_func_mat4x4()
    local result = master:CallFuncMat4x4Callback(CallbackHolder.mock_mat4x4)
    return pod_to_string(result)
end

function M.reverse_call_func1()
    local result = master:CallFunc1Callback(CallbackHolder.mock_func1)
    return tostring(result)
end

function M.reverse_call_func2()
    local result = master:CallFunc2Callback(CallbackHolder.mock_func2)
    return char8_str(result)
end

function M.reverse_call_func3()
    master:CallFunc3Callback(CallbackHolder.mock_func3)
    return ''
end

function M.reverse_call_func4()
    local result = master:CallFunc4Callback(CallbackHolder.mock_func4)
    return pod_to_string(result)
end

function M.reverse_call_func5()
    local result = master:CallFunc5Callback(CallbackHolder.mock_func5)
    return bool_str(result)
end

function M.reverse_call_func6()
    local result = master:CallFunc6Callback(CallbackHolder.mock_func6)
    return tostring(result)
end

function M.reverse_call_func7()
    local result = master:CallFunc7Callback(CallbackHolder.mock_func7)
    return tostring(result)
end

function M.reverse_call_func8()
    local result = master:CallFunc8Callback(CallbackHolder.mock_func8)
    return pod_to_string(result)
end

function M.reverse_call_func9()
    master:CallFunc9Callback(CallbackHolder.mock_func9)
    return ''
end

function M.reverse_call_func10()
    local result = master:CallFunc10Callback(CallbackHolder.mock_func10)
    return tostring(result)
end

function M.reverse_call_func11()
    local result = master:CallFunc11Callback(CallbackHolder.mock_func11)
    return ptr_str(result)
end

function M.reverse_call_func12()
    local result = master:CallFunc12Callback(CallbackHolder.mock_func12)
    return bool_str(result)
end

function M.reverse_call_func13()
    local result = master:CallFunc13Callback(CallbackHolder.mock_func13)
    return result
end

function M.reverse_call_func14()
    local result = master:CallFunc14Callback(CallbackHolder.mock_func14)
    return vector_to_string(result, quote_str)
end

function M.reverse_call_func15()
    local result = master:CallFunc15Callback(CallbackHolder.mock_func15)
    return tostring(result)
end

function M.reverse_call_func16()
    local result = master:CallFunc16Callback(CallbackHolder.mock_func16)
    return ptr_str(result)
end

function M.reverse_call_func17()
    local result = master:CallFunc17Callback(CallbackHolder.mock_func17)
    return result
end

function M.reverse_call_func18()
    local result = master:CallFunc18Callback(CallbackHolder.mock_func18)
    return result
end

function M.reverse_call_func19()
    local result = master:CallFunc19Callback(CallbackHolder.mock_func19)
    return result
end

function M.reverse_call_func20()
    local result = master:CallFunc20Callback(CallbackHolder.mock_func20)
    return result
end

function M.reverse_call_func21()
    local result = master:CallFunc21Callback(CallbackHolder.mock_func21)
    return result
end

function M.reverse_call_func22()
    local result = master:CallFunc22Callback(CallbackHolder.mock_func22)
    return result
end

function M.reverse_call_func23()
    local result = master:CallFunc23Callback(CallbackHolder.mock_func23)
    return result
end

function M.reverse_call_func24()
    local result = master:CallFunc24Callback(CallbackHolder.mock_func24)
    return result
end

function M.reverse_call_func25()
    local result = master:CallFunc25Callback(CallbackHolder.mock_func25)
    return result
end

function M.reverse_call_func26()
    local result = master:CallFunc26Callback(CallbackHolder.mock_func26)
    return result
end

function M.reverse_call_func27()
    local result = master:CallFunc27Callback(CallbackHolder.mock_func27)
    return result
end

function M.reverse_call_func28()
    local result = master:CallFunc28Callback(CallbackHolder.mock_func28)
    return result
end

function M.reverse_call_func29()
    local result = master:CallFunc29Callback(CallbackHolder.mock_func29)
    return result
end

function M.reverse_call_func30()
    local result = master:CallFunc30Callback(CallbackHolder.mock_func30)
    return result
end

function M.reverse_call_func31()
    local result = master:CallFunc31Callback(CallbackHolder.mock_func31)
    return result
end

function M.reverse_call_func32()
    local result = master:CallFunc32Callback(CallbackHolder.mock_func32)
    return result
end

function M.reverse_call_func33()
    local result = master:CallFunc33Callback(CallbackHolder.mock_func33)
    return result
end

function M.reverse_call_func_enum()
    local result = master:CallFuncEnumCallback(CallbackHolder.mock_func_enum)
    return result
end

local function log(message)
    -- Only logs in debug mode
    if os.getenv('VERBOSE') then
        print(message)
    end
end

function M.basic_lifecycle()
    log("TEST 1: Basic Lifecycle")
    log("_______________________")

    local initial_alive = master.ResourceHandle.GetAliveCount()
    local initial_created = master.ResourceHandle.GetTotalCreated()

    do
        local resource <close> = master.ResourceHandle.new(1, "Test1")
        log(string.format("v Created ResourceHandle ID: %d", resource:GetId()))
        log(string.format("v Alive count increased: %d", master.ResourceHandle.GetAliveCount()))
    end

    local final_alive = master.ResourceHandle.GetAliveCount()
    local final_created = master.ResourceHandle.GetTotalCreated()
    local final_destroyed = master.ResourceHandle.GetTotalDestroyed()

    log(string.format("v Destructor called, alive count: %d", final_alive))
    log(string.format("v Total created: %d", final_created - initial_created))
    log(string.format("v Total destroyed: %d", final_destroyed))

    if final_alive == initial_alive and final_created == final_destroyed then
        log("v TEST 1 PASSED: Lifecycle working correctly\n")
        return "true"
    else
        log("x TEST 1 FAILED: Lifecycle mismatch!\n")
        return "false"
    end
end

function M.state_management()
    log("TEST 2: State Management")
    log("________________________")

    do
        local resource <close> = master.ResourceHandle.new(2, "StateTest")

        resource:IncrementCounter()
        resource:IncrementCounter()
        resource:IncrementCounter()
        local counter = resource:GetCounter()
        log(string.format("v Counter incremented 3 times: %d", counter))

        resource:SetName("StateTestModified")
        local new_name = resource:GetName()
        log(string.format("v Name changed to: %s", new_name))

        resource:AddData(1.1)
        resource:AddData(2.2)
        resource:AddData(3.3)
        local data = resource:GetData()
        log(string.format("v Added %d data points", #data))

        if counter == 3 and new_name == "StateTestModified" and #data == 3 then
            log("v TEST 2 PASSED: State management working\n")
            return "true"
        else
            log("x TEST 2 FAILED: State not preserved!\n")
            return "false"
        end
    end
end

function M.multiple_instances()
    log("TEST 3: Multiple Instances")
    log("__________________________")

    local before_alive = master.ResourceHandle.GetAliveCount()

    do
        local r1 <close> = master.ResourceHandle.new(10, "Instance1")
        local r2 <close> = master.ResourceHandle.new(20, "Instance2")
        local r3 <close> = master.ResourceHandle.new()

        local during_alive = master.ResourceHandle.GetAliveCount()
        log(string.format("v Created 3 instances, alive: %d", during_alive))
        log(string.format("v R1 ID: %d, R2 ID: %d, R3 ID: %d",
            r1:GetId(), r2:GetId(), r3:GetId()))

        if during_alive - before_alive == 3 then
            log("v All 3 instances tracked correctly")
        end
    end

    local after_alive = master.ResourceHandle.GetAliveCount()

    if after_alive == before_alive then
        log("v TEST 3 PASSED: All instances destroyed properly\n")
        return "true"
    else
        log(string.format("x TEST 3 FAILED: Leak detected! Before: %d, After: %d\n",
            before_alive, after_alive))
        return "false"
    end
end

function M.counter_without_destructor()
    log("TEST 4: Counter (No Destructor)")
    log("________________________________")

    local counter = master.Counter.new(100)
    log(string.format("v Created Counter with value: %d", counter:GetValue()))

    counter:Increment()
    counter:Increment()
    counter:Add(50)
    local value = counter:GetValue()
    log(string.format("v After operations, value: %d", value))

    local is_positive = counter:IsPositive()
    log(string.format("v Is positive: %s", tostring(is_positive)))

    if value == 152 and is_positive then
        log("v TEST 4 PASSED: Counter operations working\n")
        return "true"
    else
        log("x TEST 4 FAILED: Counter operations incorrect\n")
        return "false"
    end
end

function M.static_methods()
    log("TEST 5: Static Methods")
    log("______________________")

    local alive = master.ResourceHandle.GetAliveCount()
    local created = master.ResourceHandle.GetTotalCreated()
    local destroyed = master.ResourceHandle.GetTotalDestroyed()
    log(string.format("v ResourceHandle stats - Alive: %d, Created: %d, Destroyed: %d",
        alive, created, destroyed))

    local cmp1 = master.Counter.Compare(100, 50)
    local cmp2 = master.Counter.Compare(50, 100)
    local cmp3 = master.Counter.Compare(50, 50)
    log(string.format("v Counter.Compare(100, 50) = %d (expected 1)", cmp1))
    log(string.format("v Counter.Compare(50, 100) = %d (expected -1)", cmp2))
    log(string.format("v Counter.Compare(50, 50) = %d (expected 0)", cmp3))

    local sum_result = master.Counter.Sum({1, 2, 3, 4, 5})
    log(string.format("v Counter.Sum([1,2,3,4,5]) = %d (expected 15)", sum_result))

    if cmp1 == 1 and cmp2 == -1 and cmp3 == 0 and sum_result == 15 then
        log("v TEST 5 PASSED: Static methods working\n")
        return "true"
    else
        log("x TEST 5 FAILED: Static methods incorrect\n")
        return "false"
    end
end

function M.memory_leak_detection()
    log("TEST 6: Memory Leak Detection")
    log("______________________________")

    local before_alive = master.ResourceHandle.GetAliveCount()

    do
        local leaked = master.ResourceHandle.new(999, "IntentionalLeak")
        log(string.format("v Created resource ID: %d", leaked:GetId()))
        leaked = nil
    end

    collectgarbage("collect")

    local after_alive = master.ResourceHandle.GetAliveCount()

    log(string.format("v Before leak test: %d alive", before_alive))
    log(string.format("v After GC: %d alive", after_alive))

    if after_alive == before_alive then
        log("v TEST 6 PASSED: Finalizer cleaned up leaked resource\n")
        return "true"
    else
        log("x TEST 6 FAILED: Resource still alive (will be cleaned at plugin shutdown)\n")
        return "false"
    end
end

function M.exception_handling()
    log("TEST 7: Exception Handling")
    log("__________________________")

    local resource = master.ResourceHandle.new(777, "ExceptionTest")
    resource:__close()

    local success, err = pcall(function()
        resource:GetId()
    end)

    if not success then
        log(string.format("v Caught expected exception: %s", tostring(err)))
        log("v TEST 7 PASSED: Exception handling working\n")
        return "true"
    else
        log("x TEST 7 FAILED: No exception thrown!\n")
        return "false"
    end
end

function M.ownership_transfer()
    log("TEST 8: Ownership Transfer (get + release)")
    log("_________________________________________")

    local initial_alive = master.ResourceHandle.GetAliveCount()
    local initial_created = master.ResourceHandle.GetTotalCreated()

    local resource = master.ResourceHandle.new(42, "OwnershipTest")
    log(string.format("v Created ResourceHandle ID: %d", resource:GetId()))

    -- Get internal wrapper (simulate internal pointer access)
    local wrapper = resource:get()
    log(string.format("v get() returned internal wrapper: %s", tostring(wrapper)))

    -- Release ownership
    local handle = resource:release()
    log(string.format("v release() returned handle: %s", tostring(handle)))

    if wrapper ~= handle then
        log(string.format("x TEST 8 FAILED: get() did not return internal wrapper, got %s",
            type(wrapper)))
        return "false"
    end

    local success, err = pcall(function()
        resource:GetId()
    end)

    if success then
        log("x TEST 8 FAILED: ResourceHandle still accessible after release()")
        return "false"
    else
        log("v ResourceHandle is invalid after release()")
    end

    -- Check that handle is now owned externally and alive count updated correctly
    local alive_after_release = master.ResourceHandle.GetAliveCount()
    if alive_after_release ~= initial_alive + 1 then
        log(string.format("x TEST 8 FAILED: Alive count mismatch after release. Expected %d, got %d", 
            initial_alive + 1, alive_after_release))
        return "false"
    end

    master:ResourceHandleDestroy(handle)

    log("v TEST 8 PASSED: Ownership transfer working correctly\n")
    return "true"
end

local reverse_test = {
    ["NoParamReturnVoid"] = M.reverse_no_param_return_void,
    ["NoParamReturnBool"] = M.reverse_no_param_return_bool,
    ["NoParamReturnChar8"] = M.reverse_no_param_return_char8,
    ["NoParamReturnChar16"] = M.reverse_no_param_return_char16,
    ["NoParamReturnInt8"] = M.reverse_no_param_return_int8,
    ["NoParamReturnInt16"] = M.reverse_no_param_return_int16,
    ["NoParamReturnInt32"] = M.reverse_no_param_return_int32,
    ["NoParamReturnInt64"] = M.reverse_no_param_return_int64,
    ["NoParamReturnUInt8"] = M.reverse_no_param_return_uint8,
    ["NoParamReturnUInt16"] = M.reverse_no_param_return_uint16,
    ["NoParamReturnUInt32"] = M.reverse_no_param_return_uint32,
    ["NoParamReturnUInt64"] = M.reverse_no_param_return_uint64,
    ["NoParamReturnPointer"] = M.reverse_no_param_return_pointer,
    ["NoParamReturnFloat"] = M.reverse_no_param_return_float,
    ["NoParamReturnDouble"] = M.reverse_no_param_return_double,
    ["NoParamReturnFunction"] = M.reverse_no_param_return_function,
    ["NoParamReturnString"] = M.reverse_no_param_return_string,
    ["NoParamReturnAny"] = M.reverse_no_param_return_any,
    ["NoParamReturnArrayBool"] = M.reverse_no_param_return_array_bool,
    ["NoParamReturnArrayChar8"] = M.reverse_no_param_return_array_char8,
    ["NoParamReturnArrayChar16"] = M.reverse_no_param_return_array_char16,
    ["NoParamReturnArrayInt8"] = M.reverse_no_param_return_array_int8,
    ["NoParamReturnArrayInt16"] = M.reverse_no_param_return_array_int16,
    ["NoParamReturnArrayInt32"] = M.reverse_no_param_return_array_int32,
    ["NoParamReturnArrayInt64"] = M.reverse_no_param_return_array_int64,
    ["NoParamReturnArrayUInt8"] = M.reverse_no_param_return_array_uint8,
    ["NoParamReturnArrayUInt16"] = M.reverse_no_param_return_array_uint16,
    ["NoParamReturnArrayUInt32"] = M.reverse_no_param_return_array_uint32,
    ["NoParamReturnArrayUInt64"] = M.reverse_no_param_return_array_uint64,
    ["NoParamReturnArrayPointer"] = M.reverse_no_param_return_array_pointer,
    ["NoParamReturnArrayFloat"] = M.reverse_no_param_return_array_float,
    ["NoParamReturnArrayDouble"] = M.reverse_no_param_return_array_double,
    ["NoParamReturnArrayString"] = M.reverse_no_param_return_array_string,
    ["NoParamReturnArrayAny"] = M.reverse_no_param_return_array_any,
    ["NoParamReturnVector2"] = M.reverse_no_param_return_vector2,
    ["NoParamReturnVector3"] = M.reverse_no_param_return_vector3,
    ["NoParamReturnVector4"] = M.reverse_no_param_return_vector4,
    ["NoParamReturnMatrix4x4"] = M.reverse_no_param_return_matrix4x4,
    ["Param1"] = M.reverse_param1,
    ["Param2"] = M.reverse_param2,
    ["Param3"] = M.reverse_param3,
    ["Param4"] = M.reverse_param4,
    ["Param5"] = M.reverse_param5,
    ["Param6"] = M.reverse_param6,
    ["Param7"] = M.reverse_param7,
    ["Param8"] = M.reverse_param8,
    ["Param9"] = M.reverse_param9,
    ["Param10"] = M.reverse_param10,
    ["ParamRef1"] = M.reverse_param_ref1,
    ["ParamRef2"] = M.reverse_param_ref2,
    ["ParamRef3"] = M.reverse_param_ref3,
    ["ParamRef4"] = M.reverse_param_ref4,
    ["ParamRef5"] = M.reverse_param_ref5,
    ["ParamRef6"] = M.reverse_param_ref6,
    ["ParamRef7"] = M.reverse_param_ref7,
    ["ParamRef8"] = M.reverse_param_ref8,
    ["ParamRef9"] = M.reverse_param_ref9,
    ["ParamRef10"] = M.reverse_param_ref10,
    ["ParamRefArrays"] = M.reverse_param_ref_vectors,
    ["ParamAllPrimitives"] = M.reverse_param_all_primitives,
    ["ParamEnum"] = M.reverse_param_enum,
    ["ParamEnumRef"] = M.reverse_param_enum_ref,
    ["ParamVariant"] = M.reverse_param_variant,
    ["ParamVariantRef"] = M.reverse_param_variant_ref,
    ["CallFuncVoid"] = M.reverse_call_func_void,
    ["CallFuncBool"] = M.reverse_call_func_bool,
    ["CallFuncChar8"] = M.reverse_call_func_char8,
    ["CallFuncChar16"] = M.reverse_call_func_char16,
    ["CallFuncInt8"] = M.reverse_call_func_int8,
    ["CallFuncInt16"] = M.reverse_call_func_int16,
    ["CallFuncInt32"] = M.reverse_call_func_int32,
    ["CallFuncInt64"] = M.reverse_call_func_int64,
    ["CallFuncUInt8"] = M.reverse_call_func_uint8,
    ["CallFuncUInt16"] = M.reverse_call_func_uint16,
    ["CallFuncUInt32"] = M.reverse_call_func_uint32,
    ["CallFuncUInt64"] = M.reverse_call_func_uint64,
    ["CallFuncPtr"] = M.reverse_call_func_ptr,
    ["CallFuncFloat"] = M.reverse_call_func_float,
    ["CallFuncDouble"] = M.reverse_call_func_double,
    ["CallFuncString"] = M.reverse_call_func_string,
    ["CallFuncAny"] = M.reverse_call_func_any,
    ["CallFuncBoolVector"] = M.reverse_call_func_bool_vector,
    ["CallFuncChar8Vector"] = M.reverse_call_func_char8_vector,
    ["CallFuncChar16Vector"] = M.reverse_call_func_char16_vector,
    ["CallFuncInt8Vector"] = M.reverse_call_func_int8_vector,
    ["CallFuncInt16Vector"] = M.reverse_call_func_int16_vector,
    ["CallFuncInt32Vector"] = M.reverse_call_func_int32_vector,
    ["CallFuncInt64Vector"] = M.reverse_call_func_int64_vector,
    ["CallFuncUInt8Vector"] = M.reverse_call_func_uint8_vector,
    ["CallFuncUInt16Vector"] = M.reverse_call_func_uint16_vector,
    ["CallFuncUInt32Vector"] = M.reverse_call_func_uint32_vector,
    ["CallFuncUInt64Vector"] = M.reverse_call_func_uint64_vector,
    ["CallFuncPtrVector"] = M.reverse_call_func_ptr_vector,
    ["CallFuncFloatVector"] = M.reverse_call_func_float_vector,
    ["CallFuncDoubleVector"] = M.reverse_call_func_double_vector,
    ["CallFuncStringVector"] = M.reverse_call_func_string_vector,
    ["CallFuncAnyVector"] = M.reverse_call_func_any_vector,
    ["CallFuncVec2Vector"] = M.reverse_call_func_vec2_vector,
    ["CallFuncVec3Vector"] = M.reverse_call_func_vec3_vector,
    ["CallFuncVec4Vector"] = M.reverse_call_func_vec4_vector,
    ["CallFuncMat4x4Vector"] = M.reverse_call_func_mat4x4_vector,
    ["CallFuncVec2"] = M.reverse_call_func_vec2,
    ["CallFuncVec3"] = M.reverse_call_func_vec3,
    ["CallFuncVec4"] = M.reverse_call_func_vec4,
    ["CallFuncMat4x4"] = M.reverse_call_func_mat4x4,
    ["CallFunc1"] = M.reverse_call_func1,
    ["CallFunc2"] = M.reverse_call_func2,
    ["CallFunc3"] = M.reverse_call_func3,
    ["CallFunc4"] = M.reverse_call_func4,
    ["CallFunc5"] = M.reverse_call_func5,
    ["CallFunc6"] = M.reverse_call_func6,
    ["CallFunc7"] = M.reverse_call_func7,
    ["CallFunc8"] = M.reverse_call_func8,
    ["CallFunc9"] = M.reverse_call_func9,
    ["CallFunc10"] = M.reverse_call_func10,
    ["CallFunc11"] = M.reverse_call_func11,
    ["CallFunc12"] = M.reverse_call_func12,
    ["CallFunc13"] = M.reverse_call_func13,
    ["CallFunc14"] = M.reverse_call_func14,
    ["CallFunc15"] = M.reverse_call_func15,
    ["CallFunc16"] = M.reverse_call_func16,
    ["CallFunc17"] = M.reverse_call_func17,
    ["CallFunc18"] = M.reverse_call_func18,
    ["CallFunc19"] = M.reverse_call_func19,
    ["CallFunc20"] = M.reverse_call_func20,
    ["CallFunc21"] = M.reverse_call_func21,
    ["CallFunc22"] = M.reverse_call_func22,
    ["CallFunc23"] = M.reverse_call_func23,
    ["CallFunc24"] = M.reverse_call_func24,
    ["CallFunc25"] = M.reverse_call_func25,
    ["CallFunc26"] = M.reverse_call_func26,
    ["CallFunc27"] = M.reverse_call_func27,
    ["CallFunc28"] = M.reverse_call_func28,
    ["CallFunc29"] = M.reverse_call_func29,
    ["CallFunc30"] = M.reverse_call_func30,
    ["CallFunc31"] = M.reverse_call_func31,
    ["CallFunc32"] = M.reverse_call_func32,
    ["CallFunc33"] = M.reverse_call_func33,
    ["CallFuncEnum"] = M.reverse_call_func_enum,
    ["ClassBasicLifecycle"] = M.basic_lifecycle,
    ["ClassStateManagement"] = M.state_management,
    ["ClassMultipleInstances"] = M.multiple_instances,
    ["ClassCounterWithoutDestructor"] = M.counter_without_destructor,
    ["ClassStaticMethods"] = M.static_methods,
    ["ClassMemoryLeakDetection"] = M.memory_leak_detection,
    ["ClassExceptionHandling"] = M.exception_handling,
    ["ClassOwnershipTransfer"] = M.ownership_transfer,
}

-- Function to call the test function by name and handle its result
function M.reverse_call(test)
    local func = reverse_test[test]
    if func then
        local result = func()
        if result ~= nil then
            master:ReverseReturn(result)
        end
    end
end

-- Return the module table with all functions
return M
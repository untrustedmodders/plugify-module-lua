local Plugin = {}
Plugin.__index = Plugin
Plugin.__type = "Plugin"

function Plugin:new(id, name, full_name, description, version, author, website, base_dir, configs_dir, data_dir, logs_dir, dependencies)
    local self = setmetatable({}, Plugin)
    self.id = id
	self.name = name
	self.full_name = full_name
	self.description = description
	self.version = version
	self.author = author
	self.website = website
	self.base_dir = base_dir
	self.configs_dir = configs_dir
	self.data_dir = data_dir
	self.logs_dir = logs_dir
	self.dependencies = dependencies or {}
    return self
end

Plugin.__tostring = function(self)
    return string.format("Plugin(id=%s, name=%s)", tostring(self.id), tostring(self.name))
end

Vector2 = {}
Vector2.__index = Vector2
Vector2.__type = "Vector2"

-- Constructor
function Vector2.new(x, y)
    local self = setmetatable({}, Vector2)
    self.x = x or 0
    self.y = y or 0
    return self
end

-- Basic operations
function Vector2:add(other)
    return Vector2.new(self.x + other.x, self.y + other.y)
end

function Vector2:sub(other)
    return Vector2.new(self.x - other.x, self.y - other.y)
end

function Vector2:mul(scalar)
    return Vector2.new(self.x * scalar, self.y * scalar)
end

function Vector2:div(scalar)
    return Vector2.new(self.x / scalar, self.y / scalar)
end

-- Additional operations
function Vector2:dot(other)
    return self.x * other.x + self.y * other.y
end

function Vector2:length()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector2:normalized()
    local len = self:length()
    if len > 0 then
        return self:div(len)
    end
    return Vector2.new(0, 0)
end

function Vector2:distance(other)
    return math.sqrt((self.x - other.x)^2 + (self.y - other.y)^2)
end

function Vector2:lerp(target, t)
    t = math.max(0, math.min(1, t)) -- Clamp t between 0 and 1
    return Vector2.new(
        self.x + (target.x - self.x) * t,
        self.y + (target.y - self.y) * t
    )
end

-- Comparison
function Vector2:equals(other)
    return self.x == other.x and self.y == other.y
end

-- To string
function Vector2:__tostring()
    return string.format("Vector2(%f, %f)", self.x, self.y)
end

-- Overload operators
function Vector2.__add(a, b)
    return a:add(b)
end

function Vector2.__sub(a, b)
    return a:sub(b)
end

function Vector2.__mul(a, b)
    if type(a) == "number" then
        return b:mul(a)
    elseif type(b) == "number" then
        return a:mul(b)
    else
        return a:dot(b)
    end
end

function Vector2.__div(a, b)
    if type(b) == "number" then
        return a:div(b)
    else
        error("Cannot divide vector by vector")
    end
end

function Vector2.__eq(a, b)
    return a:equals(b)
end

Vector3 = {}
Vector3.__index = Vector3
Vector3.__type = "Vector3"

-- Constructor
function Vector3.new(x, y, z)
    local self = setmetatable({}, Vector3)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    return self
end

-- Constants
Vector3.zero = Vector3.new(0, 0, 0)
Vector3.one = Vector3.new(1, 1, 1)
Vector3.up = Vector3.new(0, 1, 0)
Vector3.down = Vector3.new(0, -1, 0)
Vector3.left = Vector3.new(-1, 0, 0)
Vector3.right = Vector3.new(1, 0, 0)
Vector3.forward = Vector3.new(0, 0, 1)
Vector3.back = Vector3.new(0, 0, -1)

-- Basic operations
function Vector3:add(other)
    return Vector3.new(self.x + other.x, self.y + other.y, self.z + other.z)
end

function Vector3:sub(other)
    return Vector3.new(self.x - other.x, self.y - other.y, self.z - other.z)
end

function Vector3:mul(scalar)
    return Vector3.new(self.x * scalar, self.y * scalar, self.z * scalar)
end

function Vector3:div(scalar)
    return Vector3.new(self.x / scalar, self.y / scalar, self.z / scalar)
end

-- Vector operations
function Vector3:dot(other)
    return self.x * other.x + self.y * other.y + self.z * other.z
end

function Vector3:cross(other)
    return Vector3.new(
        self.y * other.z - self.z * other.y,
        self.z * other.x - self.x * other.z,
        self.x * other.y - self.y * other.x
    )
end

function Vector3:length()
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function Vector3:sqrLength()
    return self.x * self.x + self.y * self.y + self.z * self.z
end

function Vector3:normalized()
    local len = self:length()
    if len > 0 then
        return self:div(len)
    end
    return Vector3.new(0, 0, 0)
end

function Vector3:distance(other)
    return math.sqrt((self.x - other.x)^2 + (self.y - other.y)^2 + (self.z - other.z)^2)
end

function Vector3:lerp(target, t)
    t = math.max(0, math.min(1, t)) -- Clamp t between 0 and 1
    return Vector3.new(
        self.x + (target.x - self.x) * t,
        self.y + (target.y - self.y) * t,
        self.z + (target.z - self.z) * t
    )
end

-- Reflection
function Vector3:reflect(normal)
    return self - (normal * (2 * (self:dot(normal))))
end

-- Comparison
function Vector3:equals(other)
    return self.x == other.x and self.y == other.y and self.z == other.z
end

-- To string
function Vector3:__tostring()
    return string.format("Vector3(%f, %f, %f)", self.x, self.y, self.z)
end

-- Operator overloading
function Vector3.__add(a, b)
    return a:add(b)
end

function Vector3.__sub(a, b)
    return a:sub(b)
end

function Vector3.__mul(a, b)
    if type(a) == "number" then
        return b:mul(a)
    elseif type(b) == "number" then
        return a:mul(b)
    else
        return a:dot(b)
    end
end

function Vector3.__div(a, b)
    if type(b) == "number" then
        return a:div(b)
    else
        error("Cannot divide vector by vector")
    end
end

function Vector3.__eq(a, b)
    return a:equals(b)
end

function Vector3.__unm(a)
    return a:mul(-1)
end

Vector4 = {}
Vector4.__index = Vector4
Vector4.__type = "Vector4"

-- Constructor
function Vector4.new(x, y, z, w)
    local self = setmetatable({}, Vector4)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    self.w = w or 0
    return self
end

-- Constants
Vector4.zero = Vector4.new(0, 0, 0, 0)
Vector4.one = Vector4.new(1, 1, 1, 1)
Vector4.unitX = Vector4.new(1, 0, 0, 0)
Vector4.unitY = Vector4.new(0, 1, 0, 0)
Vector4.unitZ = Vector4.new(0, 0, 1, 0)
Vector4.unitW = Vector4.new(0, 0, 0, 1)

-- Basic operations
function Vector4:add(other)
    return Vector4.new(
        self.x + other.x,
        self.y + other.y,
        self.z + other.z,
        self.w + other.w
    )
end

function Vector4:sub(other)
    return Vector4.new(
        self.x - other.x,
        self.y - other.y,
        self.z - other.z,
        self.w - other.w
    )
end

function Vector4:mul(scalar)
    return Vector4.new(
        self.x * scalar,
        self.y * scalar,
        self.z * scalar,
        self.w * scalar
    )
end

function Vector4:div(scalar)
    return Vector4.new(
        self.x / scalar,
        self.y / scalar,
        self.z / scalar,
        self.w / scalar
    )
end

-- Vector operations
function Vector4:dot(other)
    return self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w
end

function Vector4:length()
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w)
end

function Vector4:sqrLength()
    return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w
end

function Vector4:normalized()
    local len = self:length()
    if len > 0 then
        return self:div(len)
    end
    return Vector4.new(0, 0, 0, 0)
end

function Vector4:distance(other)
    return math.sqrt(
        (self.x - other.x)^2 +
        (self.y - other.y)^2 +
        (self.z - other.z)^2 +
        (self.w - other.w)^2
    )
end

function Vector4:lerp(target, t)
    t = math.max(0, math.min(1, t)) -- Clamp t between 0 and 1
    return Vector4.new(
        self.x + (target.x - self.x) * t,
        self.y + (target.y - self.y) * t,
        self.z + (target.z - self.z) * t,
        self.w + (target.w - self.w) * t
    )
end

-- Homogeneous projection (for 3D graphics)
function Vector4:projectTo3D()
    if self.w ~= 0 then
        return Vector4.new(
            self.x / self.w,
            self.y / self.w,
            self.z / self.w,
            1
        )
    end
    return Vector4.new(self.x, self.y, self.z, 0)
end

-- Color operations (if using as RGBA)
function Vector4:premultiplyAlpha()
    return Vector4.new(
        self.x * self.w,
        self.y * self.w,
        self.z * self.w,
        self.w
    )
end

-- Comparison
function Vector4:equals(other)
    return self.x == other.x and self.y == other.y and self.z == other.z and self.w == other.w
end

-- To string
function Vector4:__tostring()
    return string.format("Vector4(%f, %f, %f, %f)", self.x, self.y, self.z, self.w)
end

-- Operator overloading
function Vector4.__add(a, b)
    return a:add(b)
end

function Vector4.__sub(a, b)
    return a:sub(b)
end

function Vector4.__mul(a, b)
    if type(a) == "number" then
        return b:mul(a)
    elseif type(b) == "number" then
        return a:mul(b)
    else
        return a:dot(b)
    end
end

function Vector4.__div(a, b)
    if type(b) == "number" then
        return a:div(b)
    else
        error("Cannot divide vector by vector")
    end
end

function Vector4.__eq(a, b)
    return a:equals(b)
end

function Vector4.__unm(a)
    return a:mul(-1)
end

Matrix4x4 = {}
Matrix4x4.__index = Matrix4x4
Matrix4x4.__type = "Matrix4x4"

-- Compatibility layer
local unpack = unpack or table.unpack

-- Constructor with multiple forms:
-- 1. No args: identity matrix
-- 2. 16 scalars: m11, m12, ..., m44
-- 3. Nested table (4x4): {{m11,m12,m13,m14}, {m21,...}, ...}
-- 4. Flat array (16 elements): {m11,m12,m13,m14, m21,...}
function Matrix4x4.new(...)
    local self = setmetatable({}, Matrix4x4)
    local args = {...}
    
    -- Initialize as 4x4 array
    self.m = {
        {1, 0, 0, 0},
        {0, 1, 0, 0},
        {0, 0, 1, 0},
        {0, 0, 0, 1}
    }
    
    if #args == 0 then
        return self -- return identity matrix
    elseif #args == 16 then
        -- 16 scalar arguments
        for i = 1, 4 do
            for j = 1, 4 do
                self.m[i][j] = args[(i-1)*4 + j]
            end
        end
    elseif #args == 1 and type(args[1]) == "table" then
        local input = args[1]
        
        if #input == 16 then
            -- Flat array (16 elements)
            for i = 1, 4 do
                for j = 1, 4 do
                    self.m[i][j] = input[(i-1)*4 + j]
                end
            end
        elseif type(input[1]) == "table" and #input == 4 then
            -- Nested 4x4 table
            for i = 1, 4 do
                for j = 1, 4 do
                    self.m[i][j] = input[i][j] or 0
                end
            end
        else
            error("Invalid table format for Matrix4x4 constructor")
        end
    else
        error("Invalid arguments for Matrix4x4 constructor")
    end
    
    return self
end

-- Constants
Matrix4x4.identity = Matrix4x4.new()
Matrix4x4.zero = Matrix4x4.new(
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0
)

-- Matrix operations
function Matrix4x4:transpose()
    local result = Matrix4x4.new()
    for i = 1, 4 do
        for j = 1, 4 do
            result.m[i][j] = self.m[j][i]
        end
    end
    return result
end

function Matrix4x4:determinant()
    -- Helper function for 3x3 determinant
    local function det3x3(a, b, c, d, e, f, g, h, i)
        return a*(e*i - f*h) - b*(d*i - f*g) + c*(d*h - e*g)
    end
    
    local a, b, c, d = unpack(self.m[1])
    local e, f, g, h = unpack(self.m[2])
    local i, j, k, l = unpack(self.m[3])
    local m, n, o, p = unpack(self.m[4])
    
    return 
        a * det3x3(f, g, h, j, k, l, n, o, p) -
        b * det3x3(e, g, h, i, k, l, m, o, p) +
        c * det3x3(e, f, h, i, j, l, m, n, p) -
        d * det3x3(e, f, g, i, j, k, m, n, o)
end

function Matrix4x4:inverse()
    local det = self:determinant()
    if det == 0 then return nil end
    
    local result = Matrix4x4.new()
    local temp = {}
    
    -- Calculate cofactors
    for i = 1, 4 do
        temp[i] = {}
        for j = 1, 4 do
            -- Get 3x3 minor
            local minor = {}
            local mi = 1
            for x = 1, 4 do
                if x ~= i then
                    minor[mi] = {}
                    local mj = 1
                    for y = 1, 4 do
                        if y ~= j then
                            minor[mi][mj] = self.m[x][y]
                            mj = mj + 1
                        end
                    end
                    mi = mi + 1
                end
            end
            
            -- Calculate minor determinant
            local minorDet = minor[1][1]*(minor[2][2]*minor[3][3] - minor[2][3]*minor[3][2]) -
                           minor[1][2]*(minor[2][1]*minor[3][3] - minor[2][3]*minor[3][1]) +
                           minor[1][3]*(minor[2][1]*minor[3][2] - minor[2][2]*minor[3][1])
            
            -- Cofactor and adjugate (transposed)
            temp[i][j] = (((i+j) % 2 == 0) and 1 or -1) * minorDet / det
        end
    end
    
    -- Transpose to get inverse
    for i = 1, 4 do
        for j = 1, 4 do
            result.m[i][j] = temp[j][i]
        end
    end
    
    return result
end

-- Matrix multiplication
function Matrix4x4:mul(other)
    if type(other) == "number" then
        -- Scalar multiplication
        local result = Matrix4x4.new()
        for i = 1, 4 do
            for j = 1, 4 do
                result.m[i][j] = self.m[i][j] * other
            end
        end
        return result
    else
        -- Matrix multiplication
        local result = Matrix4x4.new()
        for i = 1, 4 do
            for j = 1, 4 do
                result.m[i][j] = 0
                for k = 1, 4 do
                    result.m[i][j] = result.m[i][j] + self.m[i][k] * other.m[k][j]
                end
            end
        end
        return result
    end
end

-- Vector transformation
function Matrix4x4:transformVector(vec)
    local result = Vector4.new(0, 0, 0, 0)
    local v = {vec.x, vec.y, vec.z, vec.w}
    
    for i = 1, 4 do
        local sum = 0
        for j = 1, 4 do
            sum = sum + self.m[i][j] * v[j]
        end
        if i == 1 then result.x = sum
        elseif i == 2 then result.y = sum
        elseif i == 3 then result.z = sum
        else result.w = sum end
    end
    
    return result
end

-- Transformation matrix creators
function Matrix4x4.createTranslation(x, y, z)
    return Matrix4x4.new(
        1, 0, 0, x or 0,
        0, 1, 0, y or 0,
        0, 0, 1, z or 0,
        0, 0, 0, 1
    )
end

function Matrix4x4.createScale(x, y, z)
    x = x or 1
    y = y or x
    z = z or x
    return Matrix4x4.new(
        x, 0, 0, 0,
        0, y, 0, 0,
        0, 0, z, 0,
        0, 0, 0, 1
    )
end

function Matrix4x4.createRotationX(angle)
    local c = math.cos(angle)
    local s = math.sin(angle)
    return Matrix4x4.new(
        1, 0,  0, 0,
        0, c, -s, 0,
        0, s,  c, 0,
        0, 0,  0, 1
    )
end

function Matrix4x4.createRotationY(angle)
    local c = math.cos(angle)
    local s = math.sin(angle)
    return Matrix4x4.new(
         c, 0, s, 0,
         0, 1, 0, 0,
        -s, 0, c, 0,
         0, 0, 0, 1
    )
end

function Matrix4x4.createRotationZ(angle)
    local c = math.cos(angle)
    local s = math.sin(angle)
    return Matrix4x4.new(
        c, -s, 0, 0,
        s,  c, 0, 0,
        0,  0, 1, 0,
        0,  0, 0, 1
    )
end

-- Perspective projection
function Matrix4x4.createPerspective(fov, aspect, near, far)
    local f = 1 / math.tan(fov * 0.5)
    local range = near - far
    
    return Matrix4x4.new(
        f / aspect, 0, 0, 0,
        0, f, 0, 0,
        0, 0, (far + near) / range, (2 * far * near) / range,
        0, 0, -1, 0
    )
end

-- Orthographic projection
function Matrix4x4.createOrthographic(left, right, bottom, top, near, far)
    local tx = -(right + left) / (right - left)
    local ty = -(top + bottom) / (top - bottom)
    local tz = -(far + near) / (far - near)
    
    return Matrix4x4.new(
        2 / (right - left), 0, 0, tx,
        0, 2 / (top - bottom), 0, ty,
        0, 0, -2 / (far - near), tz,
        0, 0, 0, 1
    )
end

-- View matrix (lookAt)
function Matrix4x4.createLookAt(eye, target, up)
    local z = (eye - target):normalized()
    local x = up:cross(z):normalized()
    local y = z:cross(x)
    
    return Matrix4x4.new(
        x.x, x.y, x.z, -x:dot(eye),
        y.x, y.y, y.z, -y:dot(eye),
        z.x, z.y, z.z, -z:dot(eye),
        0,   0,   0,   1
    )
end

-- Create rotation from axis-angle
function Matrix4x4.createFromAxisAngle(axis, angle)
    local x, y, z = axis.x, axis.y, axis.z
    local c = math.cos(angle)
    local s = math.sin(angle)
    local t = 1 - c
    
    return Matrix4x4.new(
        t*x*x + c,    t*x*y - z*s, t*x*z + y*s, 0,
        t*x*y + z*s, t*y*y + c,    t*y*z - x*s, 0,
        t*x*z - y*s, t*y*z + x*s, t*z*z + c,    0,
        0,           0,           0,           1
    )
end

-- Create shear matrix
function Matrix4x4.createShear(xy, xz, yx, yz, zx, zy)
    return Matrix4x4.new(
        1,  xy, xz, 0,
        yx, 1,  yz, 0,
        zx, zy, 1,  0,
        0,  0,  0,  1
    )
end

-- Create reflection matrix
function Matrix4x4.createReflection(normal)
    local x, y, z = normal.x, normal.y, normal.z
    local a = -2*x
    local b = -2*y
    local c = -2*z
    
    return Matrix4x4.new(
        1 + a*x, a*y,     a*z,     0,
        b*x,     1 + b*y, b*z,     0,
        c*x,     c*y,     1 + c*z, 0,
        0,       0,       0,       1
    )
end

-- To string
function Matrix4x4:__tostring()
    return string.format(
        "Matrix4x4(\n%.2f, %.2f, %.2f, %.2f\n%.2f, %.2f, %.2f, %.2f\n%.2f, %.2f, %.2f, %.2f\n%.2f, %.2f, %.2f, %.2f)",
        self.m[1][1], self.m[1][2], self.m[1][3], self.m[1][4],
        self.m[2][1], self.m[2][2], self.m[2][3], self.m[2][4],
        self.m[3][1], self.m[3][2], self.m[3][3], self.m[3][4],
        self.m[4][1], self.m[4][2], self.m[4][3], self.m[4][4]
    )
end

-- Operator overloading
function Matrix4x4.__mul(a, b)
    return a:mul(b)
end

function Matrix4x4.__eq(a, b)
    for i = 1, 4 do
        for j = 1, 4 do
            if a.m[i][j] ~= b.m[i][j] then
                return false
            end
        end
    end
    return true
end

return {
    Plugin = Plugin,
    Vector2 = Vector2,
    Vector3 = Vector3,
    Vector4 = Vector4,
    Matrix4x4 = Matrix4x4
}
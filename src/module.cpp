#include "module.hpp"
#include <bitset>
#include <filesystem>
#include <exception>

#include <plg/string.hpp>
#include <plg/any.hpp>
#include <plg/format.hpp>

#define LOG_PREFIX "[LUALM] "

using namespace plugify;
namespace fs = std::filesystem;

namespace lualm {
	extern LuaLanguageModule g_lualm;

	namespace {
		void ReplaceAll(std::string& str, const std::string& from, const std::string& to) {
			size_t start_pos{};
			while ((start_pos = str.find(from, start_pos)) != std::string::npos) {
				str.replace(start_pos, from.length(), to);
				start_pos += to.length();
			}
		}

		// Function to find the index of the flipped bit
		template<size_t N>
		constexpr size_t FindBitSetIndex(const std::bitset<N>& bitset) {
			for (size_t i = 0; i < bitset.size(); ++i) {
				if (bitset[i])
					return i;
			}
			return static_cast<size_t>(-1);
		}

		template<class T>
		constexpr bool always_false_v = std::is_same_v<std::decay_t<T>, std::add_cv_t<std::decay_t<T>>>;

		template<class T>
				constexpr bool is_vector_type_v =
						std::is_same_v<T, plg::vector<bool>> ||
						std::is_same_v<T, plg::vector<char>> ||
						std::is_same_v<T, plg::vector<char16_t>> ||
						std::is_same_v<T, plg::vector<int8_t>> ||
						std::is_same_v<T, plg::vector<int16_t>> ||
						std::is_same_v<T, plg::vector<int32_t>> ||
						std::is_same_v<T, plg::vector<int64_t>> ||
						std::is_same_v<T, plg::vector<uint8_t>> ||
						std::is_same_v<T, plg::vector<uint16_t>> ||
						std::is_same_v<T, plg::vector<uint32_t>> ||
						std::is_same_v<T, plg::vector<uint64_t>> ||
						std::is_same_v<T, plg::vector<void*>> ||
						std::is_same_v<T, plg::vector<float>> ||
						std::is_same_v<T, plg::vector<double>> ||
						std::is_same_v<T, plg::vector<plg::string>> ||
						std::is_same_v<T, plg::vector<plg::variant<plg::none>>> ||
						std::is_same_v<T, plg::vector<plg::vec2>> ||
						std::is_same_v<T, plg::vector<plg::vec3>> ||
						std::is_same_v<T, plg::vector<plg::vec4>> ||
						std::is_same_v<T, plg::vector<plg::mat4x4>>;

		template<class T>
		constexpr bool is_none_type_v =
				std::is_same_v<T, plg::invalid> ||
				std::is_same_v<T, plg::none> ||
				std::is_same_v<T, plg::variant<plg::none>> ||
				std::is_same_v<T, plg::function> ||
				std::is_same_v<T, plg::any>;

		// Return codes:
		// [1, 3]	Number bytes used
		// 0		Sequence starts with \0
		// -1		Encoding error
		// -2		Invalid multibyte sequence
		// -3		Surrogate pair
		std::pair<int, char16_t> ConvertUtf8ToUtf16(std::string_view sequence) {
			const auto c8toc16 = [](char ch) -> char16_t { return static_cast<char16_t>(static_cast<uint8_t>(ch)); };

			if (sequence.empty()) {
				return { -2, u'\0' };
			}
			const char seqCh0 = sequence[0];
			if (seqCh0 == '\0') {
				return { 0, u'\0' };
			}
			if ((seqCh0 & 0b11111000) == 0b11110000) {
				return { -3, u'\0' };
			}
			if ((seqCh0 & 0b11110000) == 0b11100000) {
				if (sequence.size() < 3) {
					return { -2, u'\0' };
				}
				const char seqCh1 = sequence[1];
				const char seqCh2 = sequence[2];
				if ((seqCh1 & 0b11000000) != 0b10000000 || (seqCh2 & 0b11000000) != 0b10000000) {
					return { -2, u'\0' };
				}
				const char16_t ch = static_cast<char16_t>((c8toc16(seqCh0 & 0b00001111) << 12) | (c8toc16(seqCh1 & 0b00111111) << 6) | c8toc16(seqCh2 & 0b00111111));
				if (0xD800 <= static_cast<uint16_t>(ch) && static_cast<uint16_t>(ch) < 0xE000) {
					return { -1, u'\0' };
				}
				return { 3, ch };
			}
			if ((seqCh0 & 0b11100000) == 0b11000000) {
				if (sequence.size() < 2) {
					return { -2, u'\0' };
				}
				const char seqCh1 = sequence[1];
				if ((seqCh1 & 0b11000000) != 0b10000000) {
					return { -2, u'\0' };
				}
				const char16_t ch = static_cast<uint16_t>((c8toc16(seqCh0 & 0b00011111) << 6) | c8toc16(seqCh1 & 0b00111111));
				return { 2, ch };
			}
			if ((seqCh0 & 0b10000000) == 0b00000000) {
				return { 1, c8toc16(seqCh0) };
			}
			return { -1, u'\0' };
		}

		// Return codes:
		// [1, 3]	Number bytes returned
		// 0		For 0x0000 symbol
		// -1		Surrogate pair
		std::pair<int, std::array<char, 4>> ConvertUtf16ToUtf8(char16_t ch16) {
			const auto c16toc8 = [](char16_t ch) -> char { return static_cast<char>(static_cast<uint8_t>(ch)); };

			if (ch16 == u'\0') {
				return { 0, {} };
			}
			if (static_cast<uint16_t>(ch16) < 0x80) {
				return { 1, { c16toc8(ch16), '\0' } };
			}
			if (static_cast<uint16_t>(ch16) < 0x800) {
				return { 2, { c16toc8(((ch16 & 0b11111000000) >> 6) | 0b11000000), c16toc8((ch16 & 0b111111) | 0b10000000), '\0' } };
			}
			if (0xD800 <= static_cast<uint16_t>(ch16) && static_cast<uint16_t>(ch16) < 0xE000) {
				return { -1, {} };
			}
			return { 3, { c16toc8(((ch16 & 0b1111000000000000) >> 12) | 0b11100000), c16toc8(((ch16 & 0b111111000000) >> 6) | 0b10000000), c16toc8((ch16 & 0b111111) | 0b10000000), '\0' } };
		}

		// Generic function to check if value is in range of type N
		template<typename T, typename U = T>
		bool IsInRange(T value) {
			if constexpr (std::is_same_v<U, T>) {
				return true;
			} else if constexpr (std::is_floating_point_v<T> && std::is_floating_point_v<U>) {
				// Handle floating-point range checks
				return value >= static_cast<T>(-std::numeric_limits<U>::infinity()) &&
					   value <= static_cast<T>(std::numeric_limits<U>::infinity());
			} else if constexpr (std::is_signed_v<T> == std::is_signed_v<U>) {
				// Both T and N are signed or unsigned
				return value >= static_cast<T>(std::numeric_limits<U>::min()) &&
					   value <= static_cast<T>(std::numeric_limits<U>::max());
			} else if constexpr (std::is_unsigned_v<T> && std::is_signed_v<U>) {
				// T is unsigned, N is signed
				if (value > static_cast<T>(std::numeric_limits<U>::max())) {
					return false;
				}
				return true;
			} else if constexpr (std::is_signed_v<T> && std::is_unsigned_v<U>) {
				// T is signed, N is unsigned
				if (value < 0 || static_cast<std::make_unsigned_t<T>>(value) > std::numeric_limits<U>::max()) {
					return false;
				}
				return true;
			}
		}

		namespace detail {
			void InternalCall(const Method* method, MemAddr data, uint64_t* params, size_t count, void* ret) {
				g_lualm.InternalCall(*method, data, params, count, ret);
			}

			void ExternalCall(const Method* method, MemAddr data, uint64_t* params, size_t count, void* ret) {
				g_lualm.ExternalCall(*method, data, params, count, ret);
			}
		}

		void LoadFile(const Method*, MemAddr data, uint64_t* parameters, size_t count, void* return_) {
			ParametersSpan params(parameters, count);
			ReturnSlot ret(return_, ValueUtils::SizeOf(ValueType::Int32));

			// int (openf*)(lua_State* L)
			const auto L = params.Get<lua_State*>(0);
			const auto* filename = data.RCast<const char*>();

			if (luaL_dofile(L, filename) != LUA_OK) {
				g_lualm.GetProvider()->Log(std::format(LOG_PREFIX "Failed to load module: {} - {}", filename, lua_tostring(L, -1)), Severity::Error);
				lua_pop(L, 1);
				ret.Set<int>(0);
				return;
			}

			ret.Set<int>(1);
		}

		int LoadEmpty(lua_State* L) {
			static const luaL_Reg funcs[] = {
				{nullptr, nullptr}
			};
			lua_newtable(L);
			luaL_setfuncs(L, funcs, 0);
			return 1;
		}

		int CustomRequire(lua_State* L) {
			if (const char* modname = lua_tostring(L, 1)) {
				g_lualm.ResolveRequiredModule(modname);
			}

			lua_rawgeti(L, LUA_REGISTRYINDEX, g_lualm._originalRequireRef);
			lua_insert(L, 1);
			lua_call(L, lua_gettop(L) - 1, 1);
			return 1;
		}
	}

	template<typename T>
	std::optional<T> LuaLanguageModule::ValueFromObject([[maybe_unused]] int arg) {
		static_assert(always_false_v<T>, "ValueFromObject specialization required");
		return std::nullopt;
	}

	template<>
	std::optional<bool> LuaLanguageModule::ValueFromObject(int arg) {
		if (lua_isboolean(_L, arg)) {
			return lua_toboolean(_L, arg);
		}
		luaL_typeerror(_L, arg, lua_typename(_L, LUA_TBOOLEAN));
		return std::nullopt;
	}

	template<>
	std::optional<char> LuaLanguageModule::ValueFromObject(int arg) {
		if (lua_isstring(_L, arg)) {
			size_t length{};
			const char* str = lua_tolstring(_L, arg, &length);
			if (length == 0) {
				return '\0';
			}
			if (length == 1) {
				char ch = str[0];
				if ((ch & 0x80) == 0) {
					return ch;
				}
				// Can't pass multibyte character
				luaL_argerror(_L, arg, "Multibyte character");
			}
			else {
				luaL_argerror(_L, arg, "Length bigger than 1");
			}
			return std::nullopt;
		}
		luaL_typeerror(_L, arg, lua_typename(_L, LUA_TSTRING));
		return std::nullopt;
	}

	template<>
	std::optional<char16_t> LuaLanguageModule::ValueFromObject(int arg) {
		if (lua_isstring(_L, arg)) {
			size_t length{};
			const char* str = lua_tolstring(_L, arg, &length);
			if (length == 0) {
				return u'\0';
			}
			if (length < 4) {
				auto [rc, ch] = ConvertUtf8ToUtf16(str);
				switch (rc) {
				case 0:
				case 1:
				case 2:
				case 3:
					return ch;
				case -3:
					luaL_argerror(_L, arg, "surrogate pair");
					break;
				case -2:
					luaL_argerror(_L, arg, "invalid multibyte character");
					break;
				case -1:
					luaL_argerror(_L, arg, "encoding error");
					break;
				}
			}
			else {
				luaL_argerror(_L, arg, "length bigger than 3");
			}
			return std::nullopt;
		}
		luaL_typeerror(_L, arg, lua_typename(_L, LUA_TSTRING));
		return std::nullopt;
	}

	template<typename T, typename V> requires(std::is_signed_v<T> || std::is_unsigned_v<T>)
	std::optional<T> LuaLanguageModule::ValueFromIntegerObject(int arg) {
		if (lua_isinteger(_L, arg)) {
			int isnum{};
			const V castResult = static_cast<V>(lua_tointegerx(_L, arg, &isnum));
			if (isnum) {
				if (IsInRange<V, T>(castResult)) {
					return static_cast<T>(castResult);
				}
				luaL_argerror(_L, arg, "overflow error");
			}
			luaL_argerror(_L, arg, "convertion error");
			return std::nullopt;
		}
		luaL_typeerror(_L, arg, lua_typename(_L, LUA_TNUMBER));
		return std::nullopt;
	}

	template<typename T, typename V> requires(std::is_floating_point_v<T>)
	std::optional<T> LuaLanguageModule::ValueFromNumberObject(int arg) {
		if (lua_isnumber(_L, arg)) {
			int isnum{};
			const V castResult = lua_tonumberx(_L, arg, &isnum);
			if (isnum) {
				if (IsInRange<V, T>(castResult)) {
					return static_cast<T>(castResult);
				}
				luaL_argerror(_L, arg, "overflow error");
			}
			luaL_argerror(_L, arg, "convertion error");
			return std::nullopt;
		}
		luaL_typeerror(_L, arg, lua_typename(_L, LUA_TNUMBER));
		return std::nullopt;
	}

	template<>
	std::optional<int8_t> LuaLanguageModule::ValueFromObject(int arg) {
		return ValueFromIntegerObject<int8_t, lua_Integer>(arg);
	}

	template<>
	std::optional<int16_t> LuaLanguageModule::ValueFromObject(int arg) {
		return ValueFromIntegerObject<int16_t, lua_Integer>(arg);
	}

	template<>
	std::optional<int32_t> LuaLanguageModule::ValueFromObject(int arg) {
		return ValueFromIntegerObject<int32_t, lua_Integer>(arg);
	}

	template<>
	std::optional<int64_t> LuaLanguageModule::ValueFromObject(int arg) {
		return ValueFromIntegerObject<int64_t, lua_Integer>(arg);
	}

	template<>
	std::optional<uint8_t> LuaLanguageModule::ValueFromObject(int arg) {
		return ValueFromIntegerObject<uint8_t, lua_Unsigned>(arg);
	}

	template<>
	std::optional<uint16_t> LuaLanguageModule::ValueFromObject(int arg) {
		return ValueFromIntegerObject<uint16_t, lua_Unsigned>(arg);
	}

	template<>
	std::optional<uint32_t> LuaLanguageModule::ValueFromObject(int arg) {
		return ValueFromIntegerObject<uint32_t, lua_Unsigned>(arg);
	}

	template<>
	std::optional<uint64_t> LuaLanguageModule::ValueFromObject(int arg) {
		return ValueFromIntegerObject<uint64_t, lua_Unsigned>(arg);
	}

	template<>
	std::optional<void*> LuaLanguageModule::ValueFromObject(int arg) {
		if (lua_isinteger(_L, arg)) {
			int isnum{};
			const lua_Integer castResult = lua_tointegerx(_L, arg, &isnum);
			if (isnum) {
				return reinterpret_cast<void*>(castResult);
			}
			luaL_argerror(_L, arg, "convertion error");
			return std::nullopt;
		}
		luaL_typeerror(_L, arg, "integer"/*lua_typename(_L, LUA_TNUMBER)*/);
		return std::nullopt;
	}

	template<>
	std::optional<float> LuaLanguageModule::ValueFromObject(int arg) {
		return ValueFromNumberObject<float, lua_Number>(arg);
	}

	template<>
	std::optional<double> LuaLanguageModule::ValueFromObject(int arg) {
		return ValueFromNumberObject<double, lua_Number>(arg);
	}

	template<>
	std::optional<plg::string> LuaLanguageModule::ValueFromObject(int arg) {
		if (lua_isstring(_L, arg)) {
			size_t length{};
			const char* str = lua_tolstring(_L, arg, &length);
			return plg::string(str, length);
		}
		luaL_typeerror(_L, arg, lua_typename(_L, LUA_TSTRING));
		return std::nullopt;
	}

	std::pair<LuaAbstractType, const char*> LuaLanguageModule::GetObjectType(int arg) const {
		int type = lua_type(_L, arg);
		if (type == LUA_TNUMBER) {
			if (lua_isinteger(_L, arg)) {
				return { LuaAbstractType::Integer, "integer" };
			}
			if (lua_isnumber(_L, arg)) {
				return { LuaAbstractType::Number, "number" };
			}
		}
		if (type == LUA_TTABLE) {
			const int absIndex = lua_absindex(_L, arg);
			if (lua_getmetatable(_L, absIndex)) {
				lua_getfield(_L, -1, "__type");
				if (lua_isstring(_L, -1)) {
					const std::string_view name = lua_tostring(_L, -1);
					if (name == "Vector2") {
						lua_pop(_L, 2);
						return { LuaAbstractType::Vector2, "vector2" };
					}
					if (name == "Vector3") {
						lua_pop(_L, 2);
						return { LuaAbstractType::Vector3, "vector3" };
					}
					if (name == "Vector4") {
						lua_pop(_L, 2);
						return { LuaAbstractType::Vector4, "vector4" };
					}
					if (name == "Matrix4x4") {
						lua_pop(_L, 2);
						return { LuaAbstractType::Matrix4x4, "matrix4x4" };
					}
				}
				lua_pop(_L, 2);
			}
			return { LuaAbstractType::Table, "table" };
		}
		return { static_cast<LuaAbstractType>(type), lua_typename(_L, type) };
	}

	template<typename T>
	std::optional<T> LuaLanguageModule::GetObjectAttrAsValue(int absIndex, const char* attrName) {
		lua_getfield(_L, absIndex, attrName);
		if (!lua_isnumber(_L, -1)) {
			auto type = lua_type(_L, -1);
			lua_pop(_L, 1);
			luaL_error(_L, "Field '%s' %s expected, got %s", attrName, lua_typename(_L, LUA_TNUMBER), lua_typename(_L, type));
			return std::nullopt;
		}
		const auto value = ValueFromObject<float>(-1);
		lua_pop(_L, 1);
		return value;
	}

	template<>
	std::optional<plg::vec2> LuaLanguageModule::ValueFromObject(int arg) {
		if (!lua_istable(_L, arg)) {
			luaL_typeerror(_L, arg, lua_typename(_L, LUA_TTABLE));
			return std::nullopt;
		}

		const int absIndex = lua_absindex(_L, arg);

		if (lua_getmetatable(_L, absIndex)) {
			lua_getfield(_L, -1, "__type");
			if (lua_isstring(_L, -1)) {
				if (const std::string_view name = lua_tostring(_L, -1); name != "Vector2") {
					lua_pop(_L, 2);
					luaL_typeerror(_L, arg, "vector2");
					return std::nullopt;
				}
			}
			lua_pop(_L, 2);
		} else {
			luaL_typeerror(_L, arg, "Vector2 (missing metatable)");
			return std::nullopt;
		}

		auto xValue = GetObjectAttrAsValue<float>(absIndex, "x");
		if (!xValue) {
			return std::nullopt;
		}
		auto yValue = GetObjectAttrAsValue<float>(absIndex, "y");
		if (!yValue) {
			return std::nullopt;
		}

		return plg::vec2{ *xValue, *yValue };
	}

	template<>
	std::optional<plg::vec3> LuaLanguageModule::ValueFromObject(int arg) {
		if (!lua_istable(_L, arg)) {
			luaL_typeerror(_L, arg, lua_typename(_L, LUA_TTABLE));
			return std::nullopt;
		}

		const int absIndex = lua_absindex(_L, arg);

		if (lua_getmetatable(_L, absIndex)) {
			lua_getfield(_L, -1, "__type");
			if (lua_isstring(_L, -1)) {
				if (const std::string_view name = lua_tostring(_L, -1); name != "Vector3") {
					lua_pop(_L, 2);
					luaL_typeerror(_L, arg, "vector3");
					return std::nullopt;
				}
			}
			lua_pop(_L, 2);
		} else {
			luaL_typeerror(_L, arg, "Vector3 (missing metatable)");
			return std::nullopt;
		}

		auto xValue = GetObjectAttrAsValue<float>(absIndex, "x");
		if (!xValue) {
			return std::nullopt;
		}
		auto yValue = GetObjectAttrAsValue<float>(absIndex, "y");
		if (!yValue) {
			return std::nullopt;
		}
		auto zValue = GetObjectAttrAsValue<float>(absIndex, "z");
		if (!zValue) {
			return std::nullopt;
		}

		return plg::vec3{ *xValue, *yValue, *zValue };
	}

	template<>
	std::optional<plg::vec4> LuaLanguageModule::ValueFromObject(int arg) {
		if (!lua_istable(_L, arg)) {
			luaL_typeerror(_L, arg, lua_typename(_L, LUA_TTABLE));
			return std::nullopt;
		}

		const int absIndex = lua_absindex(_L, arg);

		if (lua_getmetatable(_L, absIndex)) {
			lua_getfield(_L, -1, "__type");
			if (lua_isstring(_L, -1)) {
				if (const std::string_view name = lua_tostring(_L, -1); name != "Vector4") {
					lua_pop(_L, 2);
					luaL_typeerror(_L, arg, "vector4");
					return std::nullopt;
				}
			}
			lua_pop(_L, 2);
		} else {
			luaL_typeerror(_L, arg, "Vector4 (missing metatable)");
			return std::nullopt;
		}

		auto xValue = GetObjectAttrAsValue<float>(absIndex, "x");
		if (!xValue) {
			return std::nullopt;
		}
		auto yValue = GetObjectAttrAsValue<float>(absIndex, "y");
		if (!yValue) {
			return std::nullopt;
		}
		auto zValue = GetObjectAttrAsValue<float>(absIndex, "z");
		if (!zValue) {
			return std::nullopt;
		}
		auto wValue = GetObjectAttrAsValue<float>(absIndex, "w");
		if (!wValue) {
			return std::nullopt;
		}

		return plg::vec4{ *xValue, *yValue, *zValue, *wValue };
	}

	template<>
	std::optional<plg::mat4x4> LuaLanguageModule::ValueFromObject(int arg) {
		if (!lua_istable(_L, arg)) {
			luaL_typeerror(_L, arg, lua_typename(_L, LUA_TTABLE));
			return std::nullopt;
		}

		const int absIndex = lua_absindex(_L, arg);

		if (lua_getmetatable(_L, absIndex)) {
			lua_getfield(_L, -1, "__type");
			if (lua_isstring(_L, -1)) {
				if (const std::string_view name = lua_tostring(_L, -1); name != "Matrix4x4") {
					lua_pop(_L, 2);
					luaL_typeerror(_L, arg, "matrix4x4");
					return std::nullopt;
				}
			}
			lua_pop(_L, 2);
		} else {
			luaL_typeerror(_L, arg, "Matrix4x4 (missing metatable)");
			return std::nullopt;
		}

		lua_getfield(_L, absIndex, "m");
		if (!lua_istable(_L, -1)) {
			lua_pop(_L, 1);
			luaL_argerror(_L, arg, "'elements' field must be a 4x4 table");
			return std::nullopt;
		}

		plg::mat4x4 matrix{};
		int idx = 0;

		for (int i = 1; i <= 4; ++i) {
			lua_rawgeti(_L, -1, i);
			if (!lua_istable(_L, -1)) {
				lua_pop(_L, 2);
				luaL_argerror(_L, arg, "each row in 'elements' must be a table");
				return std::nullopt;
			}

			for (int j = 1; j <= 4; ++j) {
				lua_rawgeti(_L, -1, j);
				auto m = ValueFromObject<float>(-1);
				if (!m) {
					lua_pop(_L, 3);
					luaL_error(_L, "element (%d, %d) must be number", i, j);
					return std::nullopt;
				}
				matrix.data[idx++] = *m;
				lua_pop(_L, 1);
			}

			lua_pop(_L, 1);
		}

		lua_pop(_L, 1);
		return matrix;
	}

	template<>
	std::optional<plg::any> LuaLanguageModule::ValueFromObject(int arg) {
		auto [type, name] = GetObjectType(arg);
		switch (type) {
			case LuaAbstractType::Integer:
				return lua_tointeger(_L, arg);
			case LuaAbstractType::Number:
				return lua_tonumber(_L, arg);
			case LuaAbstractType::Bool:
				return lua_toboolean(_L, arg);
			case LuaAbstractType::String:
				return lua_tostring(_L, arg);
			case LuaAbstractType::Table: {
				const size_t len = lua_rawlen(_L, arg);
				if (len == 0) {
					return plg::vector<int64_t>();
				}
				const int absIndex = lua_absindex(_L, arg);
				std::bitset<MaxLuaTypes> flags;
				for (lua_Integer i = 1; i <= static_cast<lua_Integer>(len); ++i) {
					lua_rawgeti(_L, absIndex, i);
					auto [valueType, _] = GetObjectType(-1);
					if (valueType != LuaAbstractType::Invalid) {
						flags.set(static_cast<size_t>(valueType));
					}
					lua_pop(_L, 1);
				}
				if (flags.count() == 1) {
					const auto flag = static_cast<LuaAbstractType>(FindBitSetIndex(flags));
					switch (flag) {
						case LuaAbstractType::Integer: {
							if (auto array = ArrayFromObject<int64_t>(arg)) {
								return std::move(*array);
							}
							return std::nullopt;
						}
						case LuaAbstractType::Number: {
							if (auto array = ArrayFromObject<double>(arg)) {
								return std::move(*array);
							}
							return std::nullopt;
						}
						case LuaAbstractType::Bool: {
							if (auto array = ArrayFromObject<bool>(arg)) {
								return std::move(*array);
							}
							return std::nullopt;
						}
						case LuaAbstractType::String: {
							if (auto array = ArrayFromObject<plg::string>(arg)) {
								return std::move(*array);
							}
							return std::nullopt;
						}
						case LuaAbstractType::Vector2: {
							if (auto array = ArrayFromObject<plg::vec2>(arg)) {
								return std::move(*array);
							}
							return std::nullopt;
						}
						case LuaAbstractType::Vector3: {
							if (auto array = ArrayFromObject<plg::vec3>(arg)) {
								return std::move(*array);
							}
							return std::nullopt;
						}
						case LuaAbstractType::Vector4: {
							if (auto array = ArrayFromObject<plg::vec4>(arg)) {
								return std::move(*array);
							}
							return std::nullopt;
						}
						case LuaAbstractType::Matrix4x4: {
							if (auto array = ArrayFromObject<plg::mat4x4>(arg)) {
								return std::move(*array);
							}
							return std::nullopt;
						}
						default:
							break;
					}
				}
				std::string error("table should contains supported types, but contains: [");
				bool first = true;
				for (lua_Integer i = 1; i <= static_cast<lua_Integer>(len); ++i) {
					lua_rawgeti(_L, absIndex, i);
					auto [_, valueName] = GetObjectType(-1);
					if (first) {
						std::format_to(std::back_inserter(error), "'{}", valueName);
						first = false;
					} else {
						std::format_to(std::back_inserter(error), "', '{}", valueName);
					}
					lua_pop(_L, 1);
				}
				error += "']";
				luaL_argerror(_L, arg, error.c_str());
				return std::nullopt;
			}
			case LuaAbstractType::Vector2:
				return ValueFromObject<plg::vec2>(arg);
			case LuaAbstractType::Vector3:
				return ValueFromObject<plg::vec3>(arg);
			case LuaAbstractType::Vector4:
				return ValueFromObject<plg::vec4>(arg);
			default:
				const std::string error(std::format("any argument not supports lua type: {} for marshalling", name));
				luaL_argerror(_L, arg, error.c_str());
				return std::nullopt;
		}
	}

	template<typename T>
	std::optional<plg::vector<T>> LuaLanguageModule::ArrayFromObject(int arg) {
		if (!lua_istable(_L, arg)) {
			luaL_typeerror(_L, arg, lua_typename(_L, LUA_TTABLE));
			return std::nullopt;
		}

		const size_t len = lua_rawlen(_L, arg);

		plg::vector<T> array;
		array.reserve(len);

		const int absIndex = lua_absindex(_L, arg);

		for (lua_Integer i = 1; i <= static_cast<lua_Integer>(len); ++i) {
			lua_rawgeti(_L, absIndex, i);
			if (auto value = ValueFromObject<T>(-1)) {
				array.emplace_back(std::move(*value));
			} else {
				lua_pop(_L, 1);
				return std::nullopt;
			}
			lua_pop(_L, 1);
		}

		return array;
	}

	using void_t = void*;

	bool LuaLanguageModule::PushLuaObject() {
		lua_pushnil(_L);
		return true;
	}

	template<typename T>
	bool LuaLanguageModule::PushLuaObject([[maybe_unused]] const T& value) {
		static_assert(always_false_v<T>, "PushLuaObject specialization required");
		return false;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const bool& value) {
		lua_pushboolean(_L, value);
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const char& value) {
		if (value == char{ 0 }) {
			lua_pushlstring(_L, "", 0);
			return true;
		}
		lua_pushlstring(_L, &value, 1);
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const char16_t& value) {
		if (value == char16_t{ 0 }) {
			lua_pushlstring(_L, "", 0);
			return true;
		}
		const auto [rc, out] = ConvertUtf16ToUtf8(value);
		if (rc == -1) {
			luaL_error(_L, "surrogate pair");
			return false;
		}
		lua_pushlstring(_L, out.data(), static_cast<size_t>(rc));
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const int8_t& value) {
		lua_pushinteger(_L, static_cast<lua_Integer>(value));
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const int16_t& value) {
		lua_pushinteger(_L, static_cast<lua_Integer>(value));
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const int32_t& value) {
		lua_pushinteger(_L, static_cast<lua_Integer>(value));
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const int64_t& value) {
		lua_pushinteger(_L, static_cast<lua_Integer>(value));
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const uint8_t& value) {
		lua_pushinteger(_L, static_cast<lua_Integer>(value));
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const uint16_t& value) {
		lua_pushinteger(_L, static_cast<lua_Integer>(value));
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const uint32_t& value) {
		lua_pushinteger(_L, static_cast<lua_Integer>(value));
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const uint64_t& value) {
		lua_pushinteger(_L, static_cast<lua_Integer>(value));
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const void_t& value) {
		lua_pushinteger(_L, reinterpret_cast<lua_Integer>(value));
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const float& value) {
		lua_pushnumber(_L, value);
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const double& value) {
		lua_pushnumber(_L, value);
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const plg::string& value) {
		lua_pushlstring(_L, value.c_str(), value.size());
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const std::string& value) {
		lua_pushlstring(_L, value.c_str(), value.size());
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const std::string_view& value) {
		lua_pushlstring(_L, value.data(), value.size());
		return true;
	}

	/*template<>
		bool LuaLanguageModule::PushLuaObject(const std::wstring_view& value) {
		std::string str = ConvertWideToUtf8(value);
		lua_pushlstring(_L, str.data(), str.size());
		return true;
	}*/

	template<>
	bool LuaLanguageModule::PushLuaObject(const std::filesystem::path& value) {
		const std::string& str = plg::as_string(value);
		lua_pushlstring(_L, str.data(), str.size());
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const plg::vec2& value) {
		lua_rawgeti(_L, LUA_REGISTRYINDEX, _vector2Ref);
		lua_pushnumber(_L, value.x); // x
		lua_pushnumber(_L, value.y); // y
		if (lua_pcall(_L, 2, 1, 0) != LUA_OK) {
			std::string errorString = std::format("Failed to create vector2: {}", lua_tostring(_L, -1));
			lua_pop(_L, 1);
			luaL_error(_L, errorString.c_str());
			return false;
		}
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const plg::vec3& value) {
		lua_rawgeti(_L, LUA_REGISTRYINDEX, _vector3Ref);
		lua_pushnumber(_L, value.x); // x
		lua_pushnumber(_L, value.y); // y
		lua_pushnumber(_L, value.z); // z
		if (lua_pcall(_L, 3, 1, 0) != LUA_OK) {
			std::string errorString = std::format("Failed to create vector3: {}", lua_tostring(_L, -1));
			lua_pop(_L, 1);
			luaL_error(_L, errorString.c_str());
			return false;
		}
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const plg::vec4& value) {
		lua_rawgeti(_L, LUA_REGISTRYINDEX, _vector4Ref);
		lua_pushnumber(_L, value.x); // x
		lua_pushnumber(_L, value.y); // y
		lua_pushnumber(_L, value.z); // z
		lua_pushnumber(_L, value.w); // w
		if (lua_pcall(_L, 4, 1, 0) != LUA_OK) {
			std::string errorString = std::format("Failed to create vector4: {}", lua_tostring(_L, -1));
			lua_pop(_L, 1);
			luaL_error(_L, errorString.c_str());
			return false;
		}
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const plg::mat4x4& value) {
		lua_rawgeti(_L, LUA_REGISTRYINDEX, _matrix4x4Ref);
		for (const auto& el : value.data) {
			lua_pushnumber(_L, el);
		}
		if (lua_pcall(_L, 16, 1, 0) != LUA_OK) {
			std::string errorString = std::format("Failed to create matrix4x4: {}", lua_tostring(_L, -1));
			lua_pop(_L, 1);
			luaL_error(_L, errorString.c_str());
			return false;
		}
		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const plg::invalid&) {
		return false;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const plg::none&) {
		return false;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const plg::variant<plg::none>&) {
		return false;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const plg::function&) {
		return false;
	}

	std::optional<void*> LuaLanguageModule::GetOrCreateFunctionValue(const Method& method, int arg) {
		if (lua_isnil(_L, arg)) {
			return nullptr;
		}

		if (!lua_isfunction(_L, arg)) {
			luaL_typeerror(_L, arg, "expected cfunction");
			return std::nullopt;
		}

		lua_pushvalue(_L, arg);
		int funcRef = luaL_ref(_L, LUA_REGISTRYINDEX);
		auto funcObj = std::make_unique<LuaFunction>(LUA_NOREF, funcRef);

		if (void* const funcAddr = FindInternal(*funcObj)) {
			return funcAddr;
		}

		JitCallback callback{};
		const MemAddr methodAddr = callback.GetJitFunc(method, &detail::InternalCall, funcObj.get());
		if (!methodAddr) {
			luaL_error(_L, "Lang module JIT failed to generate C++ wrapper from callback object '%s'", callback.GetError().data());
			return std::nullopt;
		}

		AddToFunctionsMap(methodAddr, *funcObj);
		_internalFunctions.emplace_back(std::move(callback), std::move(funcObj));

		return methodAddr;
	}

	bool LuaLanguageModule::PushOrCreateFunctionObject(const Method& method, void* funcAddr) {
		auto [_, methodRef] = FindExternal(funcAddr);
		if (methodRef != LUA_NOREF) {
			lua_rawgeti(_L, LUA_REGISTRYINDEX, methodRef);
			return true;
		}

		JitCall call{};

		const MemAddr callAddr = call.GetJitFunc(method, funcAddr);
		if (!callAddr) {
			luaL_error(_L, "Lang module JIT failed to generate c++ call wrapper '%s'", call.GetError().data());
			return false;
		}

		JitCallback callback{};

		Signature sig{};
		sig.AddArg(ValueType::Pointer);
		sig.SetRet(ValueType::Int32);

		const MemAddr methodAddr = callback.GetJitFunc(sig, &method, &detail::ExternalCall, callAddr, false);
		if (!methodAddr) {
			luaL_error(_L, "Lang module JIT failed to generate c++ lua_CFunction wrapper '%s'", callback.GetError().data());
			return false;
		}

		lua_pushcfunction(_L, methodAddr.RCast<lua_CFunction>());
		methodRef = luaL_ref(_L, LUA_REGISTRYINDEX);
		lua_rawgeti(_L, LUA_REGISTRYINDEX, methodRef);

		auto funcObj = std::make_unique<LuaFunction>(LUA_NOREF, methodRef);

		AddToFunctionsMap(funcAddr, *funcObj);
		_externalFunctions.emplace_back(std::move(callback), std::move(call), std::move(funcObj));

		return true;
	}

	template<typename T>
	bool LuaLanguageModule::PushLuaObjectList(const plg::vector<T>& value) {
		lua_newtable(_L);

		for (size_t i = 0; i < value.size(); ++i) {
			if (PushLuaObject(value[i])) {
				lua_seti(_L, -2, static_cast<int>(i + 1));
			}
		}

		return true;
	}

	template<>
	bool LuaLanguageModule::PushLuaObject(const plg::any& value) {
		bool result = true;
		plg::visit([&](auto&& val) {
			using T = std::decay_t<decltype(val)>;
			if constexpr (is_vector_type_v<T>) {
				result = PushLuaObjectList(val);
			} else if constexpr (is_none_type_v<T>) {
				result = PushLuaObject();
			} else {
				result = PushLuaObject(val);
			}
		}, value);
		return result;
	}

	template<typename T>
	void* LuaLanguageModule::CreateValue(int arg) {
		if (auto value = ValueFromObject<T>(arg)) {
			return new T(std::move(*value));
		}
		return nullptr;
	}

	template<typename T>
	void* LuaLanguageModule::CreateArray(int arg) {
		if (auto array = ArrayFromObject<T>(arg)) {
			return new plg::vector<T>(std::move(*array));
		}
		return nullptr;
	}

#pragma region InternalCall

	void LuaLanguageModule::SetFallbackReturn(ValueType retType, ReturnSlot& ret) {
		switch (retType) {
			case ValueType::Void:
				break;
			case ValueType::Bool:
			case ValueType::Char8:
			case ValueType::Char16:
			case ValueType::Int8:
			case ValueType::Int16:
			case ValueType::Int32:
			case ValueType::Int64:
			case ValueType::UInt8:
			case ValueType::UInt16:
			case ValueType::UInt32:
			case ValueType::UInt64:
			case ValueType::Pointer:
			case ValueType::Float:
			case ValueType::Double:
				// HACK: Fill all 8 byte with 0
				ret.Set<uintptr_t>({});
				break;
			case ValueType::Function:
				ret.Set<void*>(nullptr);
				break;
			case ValueType::String:
				ret.Construct<plg::string>();
				break;
			case ValueType::Any:
				ret.Construct<plg::any>();
				break;
			case ValueType::ArrayBool:
				ret.Construct<plg::vector<bool>>();
				break;
			case ValueType::ArrayChar8:
				ret.Construct<plg::vector<char>>();
				break;
			case ValueType::ArrayChar16:
				ret.Construct<plg::vector<char16_t>>();
				break;
			case ValueType::ArrayInt8:
				ret.Construct<plg::vector<int8_t>>();
				break;
			case ValueType::ArrayInt16:
				ret.Construct<plg::vector<int16_t>>();
				break;
			case ValueType::ArrayInt32:
				ret.Construct<plg::vector<int32_t>>();
				break;
			case ValueType::ArrayInt64:
				ret.Construct<plg::vector<int64_t>>();
				break;
			case ValueType::ArrayUInt8:
				ret.Construct<plg::vector<uint8_t>>();
				break;
			case ValueType::ArrayUInt16:
				ret.Construct<plg::vector<uint16_t>>();
				break;
			case ValueType::ArrayUInt32:
				ret.Construct<plg::vector<uint32_t>>();
				break;
			case ValueType::ArrayUInt64:
				ret.Construct<plg::vector<uint64_t>>();
				break;
			case ValueType::ArrayPointer:
				ret.Construct<plg::vector<void*>>();
				break;
			case ValueType::ArrayFloat:
				ret.Construct<plg::vector<float>>();
				break;
			case ValueType::ArrayDouble:
				ret.Construct<plg::vector<double>>();
				break;
			case ValueType::ArrayString:
				ret.Construct<plg::vector<plg::string>>();
				break;
			case ValueType::ArrayAny:
				ret.Construct<plg::vector<plg::any>>();
				break;
			case ValueType::ArrayVector2:
				ret.Construct<plg::vector<plg::vec2>>();
				break;
			case ValueType::ArrayVector3:
				ret.Construct<plg::vector<plg::vec3>>();
				break;
			case ValueType::ArrayVector4:
				ret.Construct<plg::vector<plg::vec4>>();
				break;
			case ValueType::ArrayMatrix4x4:
				ret.Construct<plg::vector<plg::mat4x4>>();
				break;
			case ValueType::Vector2:
				ret.Set<plg::vec2>({});
				break;
			case ValueType::Vector3:
				ret.Set<plg::vec3>({});
				break;
			case ValueType::Vector4:
				ret.Set<plg::vec4>({});
				break;
			case ValueType::Matrix4x4:
				ret.Set<plg::mat4x4>({});
				break;
			default: {
				_provider->Log(std::format(LOG_PREFIX "SetFallbackReturn unsupported type {:#x}", static_cast<uint8_t>(retType)), Severity::Fatal);
				std::terminate();
				break;
			}
		}
	}

	bool LuaLanguageModule::SetReturn(int arg, const Property& retType, ReturnSlot& ret) {
		switch (retType.GetType()) {
			case ValueType::Void:
				return true;
			case ValueType::Bool:
				if (auto value = ValueFromObject<bool>(arg)) {
					ret.Set<bool>(*value);
					return true;
				}
				break;
			case ValueType::Char8:
				if (auto value = ValueFromObject<char>(arg)) {
					ret.Set<char>(*value);
					return true;
				}
				break;
			case ValueType::Char16:
				if (auto value = ValueFromObject<char16_t>(arg)) {
					ret.Set<char16_t>(*value);
					return true;
				}
				break;
			case ValueType::Int8:
				if (auto value = ValueFromObject<int8_t>(arg)) {
					ret.Set<int8_t>(*value);
					return true;
				}
				break;
			case ValueType::Int16:
				if (auto value = ValueFromObject<int16_t>(arg)) {
					ret.Set<int16_t>(*value);
					return true;
				}
				break;
			case ValueType::Int32:
				if (auto value = ValueFromObject<int32_t>(arg)) {
					ret.Set<int32_t>(*value);
					return true;
				}
				break;
			case ValueType::Int64:
				if (auto value = ValueFromObject<int64_t>(arg)) {
					ret.Set<int64_t>(*value);
					return true;
				}
				break;
			case ValueType::UInt8:
				if (auto value = ValueFromObject<uint8_t>(arg)) {
					ret.Set<uint8_t>(*value);
					return true;
				}
				break;
			case ValueType::UInt16:
				if (auto value = ValueFromObject<uint16_t>(arg)) {
					ret.Set<uint16_t>(*value);
					return true;
				}
				break;
			case ValueType::UInt32:
				if (auto value = ValueFromObject<uint32_t>(arg)) {
					ret.Set<uint32_t>(*value);
					return true;
				}
				break;
			case ValueType::UInt64:
				if (auto value = ValueFromObject<uint64_t>(arg)) {
					ret.Set<uint64_t>(*value);
					return true;
				}
				break;
			case ValueType::Pointer:
				if (auto value = ValueFromObject<void*>(arg)) {
					ret.Set<void*>(*value);
					return true;
				}
				break;
			case ValueType::Float:
				if (auto value = ValueFromObject<float>(arg)) {
					ret.Set<float>(*value);
					return true;
				}
				break;
			case ValueType::Double:
				if (auto value = ValueFromObject<double>(arg)) {
					ret.Set<double>(*value);
					return true;
				}
				break;
			case ValueType::Function:
				if (auto value = GetOrCreateFunctionValue(*retType.GetPrototype(), arg)) {
					ret.Set<void*>(*value);
					return true;
				}
				break;
			case ValueType::String:
				if (auto value = ValueFromObject<plg::string>(arg)) {
					ret.Construct<plg::string>(std::move(*value));
					return true;
				}
				break;
			case ValueType::Any:
				if (auto value = ValueFromObject<plg::any>(arg)) {
					ret.Construct<plg::any>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayBool:
				if (auto value = ArrayFromObject<bool>(arg)) {
					ret.Construct<plg::vector<bool>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayChar8:
				if (auto value = ArrayFromObject<char>(arg)) {
					ret.Construct<plg::vector<char>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayChar16:
				if (auto value = ArrayFromObject<char16_t>(arg)) {
					ret.Construct<plg::vector<char16_t>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayInt8:
				if (auto value = ArrayFromObject<int8_t>(arg)) {
					ret.Construct<plg::vector<int8_t>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayInt16:
				if (auto value = ArrayFromObject<int16_t>(arg)) {
					ret.Construct<plg::vector<int16_t>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayInt32:
				if (auto value = ArrayFromObject<int32_t>(arg)) {
					ret.Construct<plg::vector<int32_t>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayInt64:
				if (auto value = ArrayFromObject<int64_t>(arg)) {
					ret.Construct<plg::vector<int64_t>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayUInt8:
				if (auto value = ArrayFromObject<uint8_t>(arg)) {
					ret.Construct<plg::vector<uint8_t>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayUInt16:
				if (auto value = ArrayFromObject<uint16_t>(arg)) {
					ret.Construct<plg::vector<uint16_t>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayUInt32:
				if (auto value = ArrayFromObject<uint32_t>(arg)) {
					ret.Construct<plg::vector<uint32_t>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayUInt64:
				if (auto value = ArrayFromObject<uint64_t>(arg)) {
					ret.Construct<plg::vector<uint64_t>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayPointer:
				if (auto value = ArrayFromObject<void*>(arg)) {
					ret.Construct<plg::vector<void*>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayFloat:
				if (auto value = ArrayFromObject<float>(arg)) {
					ret.Construct<plg::vector<float>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayDouble:
				if (auto value = ArrayFromObject<double>(arg)) {
					ret.Construct<plg::vector<double>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayString:
				if (auto value = ArrayFromObject<plg::string>(arg)) {
					ret.Construct<plg::vector<plg::string>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayAny:
				if (auto value = ArrayFromObject<plg::any>(arg)) {
					ret.Construct<plg::vector<plg::any>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayVector2:
				if (auto value = ArrayFromObject<plg::vec2>(arg)) {
					ret.Construct<plg::vector<plg::vec2>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayVector3:
				if (auto value = ArrayFromObject<plg::vec3>(arg)) {
					ret.Construct<plg::vector<plg::vec3>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayVector4:
				if (auto value = ArrayFromObject<plg::vec4>(arg)) {
					ret.Construct<plg::vector<plg::vec4>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::ArrayMatrix4x4:
				if (auto value = ArrayFromObject<plg::mat4x4>(arg)) {
					ret.Construct<plg::vector<plg::mat4x4>>(std::move(*value));
					return true;
				}
				break;
			case ValueType::Vector2:
				if (auto value = ValueFromObject<plg::vec2>(arg)) {
					ret.Set<plg::vec2>(*value);
					return true;
				}
				break;
			case ValueType::Vector3:
				if (auto value = ValueFromObject<plg::vec3>(arg)) {
					ret.Set<plg::vec3>(*value);
					return true;
				}
				break;
			case ValueType::Vector4:
				if (auto value = ValueFromObject<plg::vec4>(arg)) {
					ret.Set<plg::vec4>(*value);
					return true;
				}
				break;
			case ValueType::Matrix4x4:
				if (auto value = ValueFromObject<plg::mat4x4>(arg)) {
					ret.Set<plg::mat4x4>(*value);
					return true;
				}
				break;
			default: {
				_provider->Log(std::format(LOG_PREFIX "SetReturn unsupported type {:#x}", static_cast<uint8_t>(retType.GetType())), Severity::Fatal);
				std::terminate();
				break;
			}
		}

		return false;
	}

	bool LuaLanguageModule::SetRefParam(int arg, const Property& paramType, ParametersSpan& params, size_t index) {
		switch (paramType.GetType()) {
			case ValueType::Bool:
				if (auto value = ValueFromObject<bool>(arg)) {
					auto* const param = params.Get<bool*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::Char8:
				if (auto value = ValueFromObject<char>(arg)) {
					auto* const param = params.Get<char*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::Char16:
				if (auto value = ValueFromObject<char16_t>(arg)) {
					auto* const param = params.Get<char16_t*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::Int8:
				if (auto value = ValueFromObject<int8_t>(arg)) {
					auto* const param = params.Get<int8_t*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::Int16:
				if (auto value = ValueFromObject<int16_t>(arg)) {
					auto* const param = params.Get<int16_t*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::Int32:
				if (auto value = ValueFromObject<int32_t>(arg)) {
					auto* const param = params.Get<int32_t*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::Int64:
				if (auto value = ValueFromObject<int64_t>(arg)) {
					auto* const param = params.Get<int64_t*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::UInt8:
				if (auto value = ValueFromObject<uint8_t>(arg)) {
					auto* const param = params.Get<uint8_t*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::UInt16:
				if (auto value = ValueFromObject<uint16_t>(arg)) {
					auto* const param = params.Get<uint16_t*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::UInt32:
				if (auto value = ValueFromObject<uint32_t>(arg)) {
					auto* const param = params.Get<uint32_t*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::UInt64:
				if (auto value = ValueFromObject<uint64_t>(arg)) {
					auto* const param = params.Get<uint64_t*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::Pointer:
				if (auto value = ValueFromObject<void*>(arg)) {
					auto* const param = params.Get<void**>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::Float:
				if (auto value = ValueFromObject<float>(arg)) {
					auto* const param = params.Get<float*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::Double:
				if (auto value = ValueFromObject<double>(arg)) {
					auto* const param = params.Get<double*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::String:
				if (auto value = ValueFromObject<plg::string>(arg)) {
					auto* const param = params.Get<plg::string*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::Any:
				if (auto value = ValueFromObject<plg::any>(arg)) {
					auto* const param = params.Get<plg::any*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayBool:
				if (auto value = ArrayFromObject<bool>(arg)) {
					auto* const param = params.Get<plg::vector<bool>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayChar8:
				if (auto value = ArrayFromObject<char>(arg)) {
					auto* const param = params.Get<plg::vector<char>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayChar16:
				if (auto value = ArrayFromObject<char16_t>(arg)) {
					auto* const param = params.Get<plg::vector<char16_t>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayInt8:
				if (auto value = ArrayFromObject<int8_t>(arg)) {
					auto* const param = params.Get<plg::vector<int8_t>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayInt16:
				if (auto value = ArrayFromObject<int16_t>(arg)) {
					auto* const param = params.Get<plg::vector<int16_t>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayInt32:
				if (auto value = ArrayFromObject<int32_t>(arg)) {
					auto* const param = params.Get<plg::vector<int32_t>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayInt64:
				if (auto value = ArrayFromObject<int64_t>(arg)) {
					auto* const param = params.Get<plg::vector<int64_t>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayUInt8:
				if (auto value = ArrayFromObject<uint8_t>(arg)) {
					auto* const param = params.Get<plg::vector<uint8_t>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayUInt16:
				if (auto value = ArrayFromObject<uint16_t>(arg)) {
					auto* const param = params.Get<plg::vector<uint16_t>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayUInt32:
				if (auto value = ArrayFromObject<uint32_t>(arg)) {
					auto* const param = params.Get<plg::vector<uint32_t>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayUInt64:
				if (auto value = ArrayFromObject<uint64_t>(arg)) {
					auto* const param = params.Get<plg::vector<uint64_t>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayPointer:
				if (auto value = ArrayFromObject<void*>(arg)) {
					auto* const param = params.Get<plg::vector<void*>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayFloat:
				if (auto value = ArrayFromObject<float>(arg)) {
					auto* const param = params.Get<plg::vector<float>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayDouble:
				if (auto value = ArrayFromObject<double>(arg)) {
					auto* const param = params.Get<plg::vector<double>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayString:
				if (auto value = ArrayFromObject<plg::string>(arg)) {
					auto* const param = params.Get<plg::vector<plg::string>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayAny:
				if (auto value = ArrayFromObject<plg::any>(arg)) {
					auto* const param = params.Get<plg::vector<plg::any>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayVector2:
				if (auto value = ArrayFromObject<plg::vec2>(arg)) {
					auto* const param = params.Get<plg::vector<plg::vec2>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayVector3:
				if (auto value = ArrayFromObject<plg::vec3>(arg)) {
					auto* const param = params.Get<plg::vector<plg::vec3>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayVector4:
				if (auto value = ArrayFromObject<plg::vec4>(arg)) {
					auto* const param = params.Get<plg::vector<plg::vec4>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::ArrayMatrix4x4:
				if (auto value = ArrayFromObject<plg::mat4x4>(arg)) {
					auto* const param = params.Get<plg::vector<plg::mat4x4>*>(index);
					*param = std::move(*value);
					return true;
				}
				break;
			case ValueType::Vector2:
				if (auto value = ValueFromObject<plg::vec2>(arg)) {
					auto* const param = params.Get<plg::vec2*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::Vector3:
				if (auto value = ValueFromObject<plg::vec3>(arg)) {
					auto* const param = params.Get<plg::vec3*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::Vector4:
				if (auto value = ValueFromObject<plg::vec4>(arg)) {
					auto* const param = params.Get<plg::vec4*>(index);
					*param = *value;
					return true;
				}
				break;
			case ValueType::Matrix4x4:
				if (auto value = ValueFromObject<plg::mat4x4>(arg)) {
					auto* const param = params.Get<plg::mat4x4*>(index);
					*param = *value;
					return true;
				}
				break;
			default: {
				_provider->Log(std::format(LOG_PREFIX "SetRefParam unsupported type {:#x}", static_cast<uint8_t>(paramType.GetType())), Severity::Fatal);
				std::terminate();
				break;
			}
		}

		return false;
	}

	bool LuaLanguageModule::ParamToObject(const Property& paramType, ParametersSpan& params, size_t index) {
		switch (paramType.GetType()) {
			case ValueType::Bool:
				return PushLuaObject(params.Get<bool>(index));
			case ValueType::Char8:
				return PushLuaObject(params.Get<char>(index));
			case ValueType::Char16:
				return PushLuaObject(params.Get<char16_t>(index));
			case ValueType::Int8:
				return PushLuaObject(params.Get<int8_t>(index));
			case ValueType::Int16:
				return PushLuaObject(params.Get<int16_t>(index));
			case ValueType::Int32:
				return PushLuaObject(params.Get<int32_t>(index));
			case ValueType::Int64:
				return PushLuaObject(params.Get<int64_t>(index));
			case ValueType::UInt8:
				return PushLuaObject(params.Get<uint8_t>(index));
			case ValueType::UInt16:
				return PushLuaObject(params.Get<uint16_t>(index));
			case ValueType::UInt32:
				return PushLuaObject(params.Get<uint32_t>(index));
			case ValueType::UInt64:
				return PushLuaObject(params.Get<uint64_t>(index));
			case ValueType::Pointer:
				return PushLuaObject(params.Get<void*>(index));
			case ValueType::Float:
				return PushLuaObject(params.Get<float>(index));
			case ValueType::Double:
				return PushLuaObject(params.Get<double>(index));
			case ValueType::Function:
				return PushOrCreateFunctionObject(*paramType.GetPrototype(), params.Get<void*>(index));
			case ValueType::String:
				return PushLuaObject(*(params.Get<const plg::string*>(index)));
			case ValueType::Any:
				return PushLuaObject(*(params.Get<const plg::any*>(index)));
			case ValueType::ArrayBool:
				return PushLuaObjectList(*(params.Get<const plg::vector<bool>*>(index)));
			case ValueType::ArrayChar8:
				return PushLuaObjectList(*(params.Get<const plg::vector<char>*>(index)));
			case ValueType::ArrayChar16:
				return PushLuaObjectList(*(params.Get<const plg::vector<char16_t>*>(index)));
			case ValueType::ArrayInt8:
				return PushLuaObjectList(*(params.Get<const plg::vector<int8_t>*>(index)));
			case ValueType::ArrayInt16:
				return PushLuaObjectList(*(params.Get<const plg::vector<int16_t>*>(index)));
			case ValueType::ArrayInt32:
				return PushLuaObjectList(*(params.Get<const plg::vector<int32_t>*>(index)));
			case ValueType::ArrayInt64:
				return PushLuaObjectList(*(params.Get<const plg::vector<int64_t>*>(index)));
			case ValueType::ArrayUInt8:
				return PushLuaObjectList(*(params.Get<const plg::vector<uint8_t>*>(index)));
			case ValueType::ArrayUInt16:
				return PushLuaObjectList(*(params.Get<const plg::vector<uint16_t>*>(index)));
			case ValueType::ArrayUInt32:
				return PushLuaObjectList(*(params.Get<const plg::vector<uint32_t>*>(index)));
			case ValueType::ArrayUInt64:
				return PushLuaObjectList(*(params.Get<const plg::vector<uint64_t>*>(index)));
			case ValueType::ArrayPointer:
				return PushLuaObjectList(*(params.Get<const plg::vector<void*>*>(index)));
			case ValueType::ArrayFloat:
				return PushLuaObjectList(*(params.Get<const plg::vector<float>*>(index)));
			case ValueType::ArrayDouble:
				return PushLuaObjectList(*(params.Get<const plg::vector<double>*>(index)));
			case ValueType::ArrayString:
				return PushLuaObjectList(*(params.Get<const plg::vector<plg::string>*>(index)));
			case ValueType::ArrayAny:
				return PushLuaObjectList(*(params.Get<const plg::vector<plg::any>*>(index)));
			case ValueType::ArrayVector2:
				return PushLuaObjectList(*(params.Get<const plg::vector<plg::vec2>*>(index)));
			case ValueType::ArrayVector3:
				return PushLuaObjectList(*(params.Get<const plg::vector<plg::vec3>*>(index)));
			case ValueType::ArrayVector4:
				return PushLuaObjectList(*(params.Get<const plg::vector<plg::vec4>*>(index)));
			case ValueType::ArrayMatrix4x4:
				return PushLuaObjectList(*(params.Get<const plg::vector<plg::mat4x4>*>(index)));
			case ValueType::Vector2:
				return PushLuaObject(*(params.Get<plg::vec2*>(index)));
			case ValueType::Vector3:
				return PushLuaObject(*(params.Get<plg::vec3*>(index)));
			case ValueType::Vector4:
				return PushLuaObject(*(params.Get<plg::vec4*>(index)));
			case ValueType::Matrix4x4:
				return PushLuaObject(*(params.Get<plg::mat4x4*>(index)));
			default: {
				_provider->Log(std::format(LOG_PREFIX "ParamToObject unsupported type {:#x}", static_cast<uint8_t>(paramType.GetType())), Severity::Fatal);
				std::terminate();
			}
		}
	}

	bool LuaLanguageModule::ParamRefToObject(const Property& paramType, ParametersSpan& params, size_t index) {
		switch (paramType.GetType()) {
			case ValueType::Bool:
				return PushLuaObject(*(params.Get<bool*>(index)));
			case ValueType::Char8:
				return PushLuaObject(*(params.Get<char*>(index)));
			case ValueType::Char16:
				return PushLuaObject(*(params.Get<char16_t*>(index)));
			case ValueType::Int8:
				return PushLuaObject(*(params.Get<int8_t*>(index)));
			case ValueType::Int16:
				return PushLuaObject(*(params.Get<int16_t*>(index)));
			case ValueType::Int32:
				return PushLuaObject(*(params.Get<int32_t*>(index)));
			case ValueType::Int64:
				return PushLuaObject(*(params.Get<int64_t*>(index)));
			case ValueType::UInt8:
				return PushLuaObject(*(params.Get<uint8_t*>(index)));
			case ValueType::UInt16:
				return PushLuaObject(*(params.Get<uint16_t*>(index)));
			case ValueType::UInt32:
				return PushLuaObject(*(params.Get<uint32_t*>(index)));
			case ValueType::UInt64:
				return PushLuaObject(*(params.Get<uint64_t*>(index)));
			case ValueType::Pointer:
				return PushLuaObject(*(params.Get<void**>(index)));
			case ValueType::Float:
				return PushLuaObject(*(params.Get<float*>(index)));
			case ValueType::Double:
				return PushLuaObject(*(params.Get<double*>(index)));
			case ValueType::String:
				return PushLuaObject(*(params.Get<const plg::string*>(index)));
			case ValueType::Any:
				return PushLuaObject(*(params.Get<const plg::any*>(index)));
			case ValueType::ArrayBool:
				return PushLuaObjectList(*(params.Get<const plg::vector<bool>*>(index)));
			case ValueType::ArrayChar8:
				return PushLuaObjectList(*(params.Get<const plg::vector<char>*>(index)));
			case ValueType::ArrayChar16:
				return PushLuaObjectList(*(params.Get<const plg::vector<char16_t>*>(index)));
			case ValueType::ArrayInt8:
				return PushLuaObjectList(*(params.Get<const plg::vector<int8_t>*>(index)));
			case ValueType::ArrayInt16:
				return PushLuaObjectList(*(params.Get<const plg::vector<int16_t>*>(index)));
			case ValueType::ArrayInt32:
				return PushLuaObjectList(*(params.Get<const plg::vector<int32_t>*>(index)));
			case ValueType::ArrayInt64:
				return PushLuaObjectList(*(params.Get<const plg::vector<int64_t>*>(index)));
			case ValueType::ArrayUInt8:
				return PushLuaObjectList(*(params.Get<const plg::vector<uint8_t>*>(index)));
			case ValueType::ArrayUInt16:
				return PushLuaObjectList(*(params.Get<const plg::vector<uint16_t>*>(index)));
			case ValueType::ArrayUInt32:
				return PushLuaObjectList(*(params.Get<const plg::vector<uint32_t>*>(index)));
			case ValueType::ArrayUInt64:
				return PushLuaObjectList(*(params.Get<const plg::vector<uint64_t>*>(index)));
			case ValueType::ArrayPointer:
				return PushLuaObjectList(*(params.Get<const plg::vector<void*>*>(index)));
			case ValueType::ArrayFloat:
				return PushLuaObjectList(*(params.Get<const plg::vector<float>*>(index)));
			case ValueType::ArrayDouble:
				return PushLuaObjectList(*(params.Get<const plg::vector<double>*>(index)));
			case ValueType::ArrayString:
				return PushLuaObjectList(*(params.Get<const plg::vector<plg::string>*>(index)));
			case ValueType::ArrayAny:
				return PushLuaObjectList(*(params.Get<const plg::vector<plg::any>*>(index)));
			case ValueType::ArrayVector2:
				return PushLuaObjectList(*(params.Get<const plg::vector<plg::vec2>*>(index)));
			case ValueType::ArrayVector3:
				return PushLuaObjectList(*(params.Get<const plg::vector<plg::vec3>*>(index)));
			case ValueType::ArrayVector4:
				return PushLuaObjectList(*(params.Get<const plg::vector<plg::vec4>*>(index)));
			case ValueType::ArrayMatrix4x4:
				return PushLuaObjectList(*(params.Get<const plg::vector<plg::mat4x4>*>(index)));
			case ValueType::Vector2:
				return PushLuaObject(*(params.Get<plg::vec2*>(index)));
			case ValueType::Vector3:
				return PushLuaObject(*(params.Get<plg::vec3*>(index)));
			case ValueType::Vector4:
				return PushLuaObject(*(params.Get<plg::vec4*>(index)));
			case ValueType::Matrix4x4:
				return PushLuaObject(*(params.Get<plg::mat4x4*>(index)));
			default: {
				_provider->Log(std::format(LOG_PREFIX "ParamRefToObject unsupported type {:#x}", static_cast<uint8_t>(paramType.GetType())), Severity::Fatal);
				std::terminate();
			}
		}
	}

	void LuaLanguageModule::InternalCall(const Method& method, MemAddr data, uint64_t* parameters, size_t count, void* return_) {
		const auto& [pluginRef, methodRef] = *data.RCast<LuaFunction*>();
		
		const auto& retType = method.GetRetType();
		const auto& paramTypes = method.GetParamTypes();
		const size_t paramsCount = paramTypes.size();

		ParametersSpan params(parameters, count);
		ReturnSlot ret(return_, ValueUtils::SizeOf(retType.GetType()));

		int refParamsCount = 0;
		int argCount = static_cast<int>(paramsCount);

		if (pluginRef != LUA_NOREF) {
			lua_rawgeti(_L, LUA_REGISTRYINDEX, pluginRef);
		}
		lua_rawgeti(_L, LUA_REGISTRYINDEX, methodRef);
		if (pluginRef != LUA_NOREF) {
			lua_pushvalue(_L, -2); // self
			++argCount;
		}

		for (size_t index = 0; index < paramsCount; ++index) {
			const Property& paramType = paramTypes[index];
			if (paramType.IsRef()) {
				++refParamsCount;
			}

			using ParamConvertionFunc = decltype(&LuaLanguageModule::ParamToObject);
			ParamConvertionFunc const convertFunc = paramType.IsRef() ? &LuaLanguageModule::ParamRefToObject : &LuaLanguageModule::ParamToObject;
			const bool pushResult = (this->*convertFunc)(paramType, params, index);
			if (!pushResult) {
				SetFallbackReturn(retType.GetType(), ret);
				return;
			}
		}

		const bool hasRefParams = refParamsCount != 0;
		const bool hasRet = retType.GetType() != ValueType::Void || hasRefParams;
		const int returnCount = hasRet + refParamsCount;

		if (lua_pcall(_L, argCount, returnCount, 0) != LUA_OK) {
			LogError();
			lua_pop(_L, 1);
			SetFallbackReturn(retType.GetType(), ret);
			return;
		}

		if (hasRefParams) {
			int k = 0;

			for (size_t index = 0; index < paramsCount; ++index) {
				const Property& paramType = paramTypes[index];
				if (!paramType.IsRef()) {
					continue;
				}
				if (!SetRefParam(-returnCount + k + 1, paramType, params, index)) {
					LogError();
				}
				if (++k == refParamsCount) {
					break;
				}
			}
		}

		if (!SetReturn(-returnCount, retType, ret)) {
			LogError();
			SetFallbackReturn(retType.GetType(), ret);
		}

		lua_pop(_L, returnCount);
	}

#pragma endregion InternalCall

	Result<LuaMethodData> LuaLanguageModule::GenerateMethodExport(const Method& method, int pluginRef) {
		std::string_view className, methodName;
		{
			std::string_view funcName = method.GetFuncName();
			if (const auto pos = funcName.find('.'); pos != std::string::npos) {
				className = funcName.substr(0, pos);
				methodName = funcName.substr(pos + 1);
			} else {
				methodName = funcName;
			}
		}

		const bool funcIsMethod = !className.empty();

		if (funcIsMethod) {
			lua_rawgeti(_L, LUA_REGISTRYINDEX, pluginRef);
		}

		lua_getfield(_L, -1, methodName.data()); // Stack: ..., plugin, method
		if (lua_isnil(_L, -1)) {
			lua_pop(_L, funcIsMethod ? 2 : 1);  // Pop the nil
			return MakeError("not found '{}' in module", method.GetFuncName());
		}

		int methodRef = luaL_ref(_L, LUA_REGISTRYINDEX); // Pops the function and stores it in the registry

		if (funcIsMethod) {
			lua_pop(_L, 1); // Pop instance
		}

		auto funcObj = std::make_unique<LuaFunction>(funcIsMethod ? pluginRef : LUA_NOREF, methodRef);

		JitCallback callback{};
		const MemAddr methodAddr = callback.GetJitFunc(method, &detail::InternalCall, funcObj.get());
		if (!methodAddr) {
			return MakeError("jit error: {}", callback.GetError());
		}

		return LuaMethodData{ std::move(callback), std::move(funcObj) };
	}

#pragma region ExternalCall

	LuaLanguageModule::ArgsScope::ArgsScope(size_t size) : params(size) {
		storage.reserve(size);
	}

	LuaLanguageModule::ArgsScope::~ArgsScope() {
		for (auto& [ptr, type] : storage) {
			switch (type) {
				case ValueType::Bool: {
					delete static_cast<bool*>(ptr);
					break;
				}
				case ValueType::Char8: {
					delete static_cast<char*>(ptr);
					break;
				}
				case ValueType::Char16: {
					delete static_cast<char16_t*>(ptr);
					break;
				}
				case ValueType::Int8: {
					delete static_cast<int8_t*>(ptr);
					break;
				}
				case ValueType::Int16: {
					delete static_cast<int16_t*>(ptr);
					break;
				}
				case ValueType::Int32: {
					delete static_cast<int32_t*>(ptr);
					break;
				}
				case ValueType::Int64: {
					delete static_cast<int64_t*>(ptr);
					break;
				}
				case ValueType::UInt8: {
					delete static_cast<uint8_t*>(ptr);
					break;
				}
				case ValueType::UInt16: {
					delete static_cast<uint16_t*>(ptr);
					break;
				}
				case ValueType::UInt32: {
					delete static_cast<uint32_t*>(ptr);
					break;
				}
				case ValueType::UInt64: {
					delete static_cast<uint64_t*>(ptr);
					break;
				}
				case ValueType::Pointer: {
					delete static_cast<void**>(ptr);
					break;
				}
				case ValueType::Float: {
					delete static_cast<float*>(ptr);
					break;
				}
				case ValueType::Double: {
					delete static_cast<double*>(ptr);
					break;
				}
				case ValueType::String: {
					delete static_cast<plg::string*>(ptr);
					break;
				}
				case ValueType::Any: {
					delete static_cast<plg::any*>(ptr);
					break;
				}
				case ValueType::ArrayBool: {
					delete static_cast<plg::vector<bool>*>(ptr);
					break;
				}
				case ValueType::ArrayChar8: {
					delete static_cast<plg::vector<char>*>(ptr);
					break;
				}
				case ValueType::ArrayChar16: {
					delete static_cast<plg::vector<char16_t>*>(ptr);
					break;
				}
				case ValueType::ArrayInt8: {
					delete static_cast<plg::vector<int8_t>*>(ptr);
					break;
				}
				case ValueType::ArrayInt16: {
					delete static_cast<plg::vector<int16_t>*>(ptr);
					break;
				}
				case ValueType::ArrayInt32: {
					delete static_cast<plg::vector<int32_t>*>(ptr);
					break;
				}
				case ValueType::ArrayInt64: {
					delete static_cast<plg::vector<int64_t>*>(ptr);
					break;
				}
				case ValueType::ArrayUInt8: {
					delete static_cast<plg::vector<uint8_t>*>(ptr);
					break;
				}
				case ValueType::ArrayUInt16: {
					delete static_cast<plg::vector<uint16_t>*>(ptr);
					break;
				}
				case ValueType::ArrayUInt32: {
					delete static_cast<plg::vector<uint32_t>*>(ptr);
					break;
				}
				case ValueType::ArrayUInt64: {
					delete static_cast<plg::vector<uint64_t>*>(ptr);
					break;
				}
				case ValueType::ArrayPointer: {
					delete static_cast<plg::vector<void*>*>(ptr);
					break;
				}
				case ValueType::ArrayFloat: {
					delete static_cast<plg::vector<float>*>(ptr);
					break;
				}
				case ValueType::ArrayDouble: {
					delete static_cast<plg::vector<double>*>(ptr);
					break;
				}
				case ValueType::ArrayString: {
					delete static_cast<plg::vector<plg::string>*>(ptr);
					break;
				}
				case ValueType::ArrayAny: {
					delete static_cast<plg::vector<plg::any>*>(ptr);
					break;
				}
				case ValueType::ArrayVector2: {
					delete static_cast<plg::vector<plg::vec2>*>(ptr);
					break;
				}
				case ValueType::ArrayVector3: {
					delete static_cast<plg::vector<plg::vec3>*>(ptr);
					break;
				}
				case ValueType::ArrayVector4: {
					delete static_cast<plg::vector<plg::vec4>*>(ptr);
					break;
				}
				case ValueType::ArrayMatrix4x4: {
					delete static_cast<plg::vector<plg::mat4x4>*>(ptr);
					break;
				}
				case ValueType::Vector2: {
					delete static_cast<plg::vec2*>(ptr);
					break;
				}
				case ValueType::Vector3: {
					delete static_cast<plg::vec3*>(ptr);
					break;
				}
				case ValueType::Vector4: {
					delete static_cast<plg::vec4*>(ptr);
					break;
				}
				case ValueType::Matrix4x4: {
					delete static_cast<plg::mat4x4*>(ptr);
					break;
				}
				default: {
					g_lualm._provider->Log(std::format(LOG_PREFIX "[ArgsScope unhandled type {:#x}", static_cast<uint8_t>(type)), Severity::Fatal);
					std::terminate();
					break;
				}
			}
		}
	}

	void LuaLanguageModule::BeginExternalCall(ValueType retType, ArgsScope& a) const {
		void* value;
		switch (retType) {
			case ValueType::String: {
				value = new plg::string();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::Any: {
				value = new plg::any();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayBool: {
				value = new plg::vector<bool>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayChar8: {
				value = new plg::vector<char>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayChar16: {
				value = new plg::vector<char16_t>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayInt8: {
				value = new plg::vector<int8_t>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayInt16: {
				value = new plg::vector<int16_t>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayInt32: {
				value = new plg::vector<int32_t>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayInt64: {
				value = new plg::vector<int64_t>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayUInt8: {
				value = new plg::vector<uint8_t>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayUInt16: {
				value = new plg::vector<uint16_t>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayUInt32: {
				value = new plg::vector<uint32_t>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayUInt64: {
				value = new plg::vector<uint64_t>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayPointer: {
				value = new plg::vector<void*>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayFloat: {
				value = new plg::vector<float>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayDouble: {
				value = new plg::vector<double>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayString: {
				value = new plg::vector<plg::string>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayAny: {
				value = new plg::vector<plg::any>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayVector2: {
				value = new plg::vector<plg::vec2>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayVector3: {
				value = new plg::vector<plg::vec3>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayVector4: {
				value = new plg::vector<plg::vec4>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::ArrayMatrix4x4: {
				value = new plg::vector<plg::mat4x4>();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::Vector2: {
				value = new plg::vec2();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::Vector3: {
				value = new plg::vec3();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::Vector4: {
				value = new plg::vec4();
				a.storage.emplace_back(value, retType);
				break;
			}
			case ValueType::Matrix4x4: {
				value = new plg::mat4x4();
				a.storage.emplace_back(value, retType);
				break;
			}
			default:
				_provider->Log(std::format(LOG_PREFIX "BeginExternalCall unsupported type {:#x}", static_cast<uint8_t>(retType)), Severity::Fatal);
				std::terminate();
				break;
		}

		a.params.Add(value);
	}

	bool LuaLanguageModule::MakeExternalCallWithObject(const Property& retType, JitCall::CallingFunc func, const ArgsScope& a, Return& ret) {
		func(a.params.Get(), &ret);
		switch (retType.GetType()) {
			case ValueType::Void: {
				return PushLuaObject();
			}
			case ValueType::Bool: {
				const bool val = ret.Get<bool>();
				return PushLuaObject(val);
			}
			case ValueType::Char8: {
				const char val = ret.Get<char>();
				return PushLuaObject(val);
			}
			case ValueType::Char16: {
				const char16_t val = ret.Get<char16_t>();
				return PushLuaObject(val);
			}
			case ValueType::Int8: {
				const int8_t val = ret.Get<int8_t>();
				return PushLuaObject(val);
			}
			case ValueType::Int16: {
				const int16_t val = ret.Get<int16_t>();
				return PushLuaObject(val);
			}
			case ValueType::Int32: {
				const int32_t val = ret.Get<int32_t>();
				return PushLuaObject(val);
			}
			case ValueType::Int64: {
				const int64_t val = ret.Get<int64_t>();
				return PushLuaObject(val);
			}
			case ValueType::UInt8: {
				const uint8_t val = ret.Get<uint8_t>();
				return PushLuaObject(val);
			}
			case ValueType::UInt16: {
				const uint16_t val = ret.Get<uint16_t>();
				return PushLuaObject(val);
			}
			case ValueType::UInt32: {
				const uint32_t val = ret.Get<uint32_t>();
				return PushLuaObject(val);
			}
			case ValueType::UInt64: {
				const uint64_t val = ret.Get<uint64_t>();
				return PushLuaObject(val);
			}
			case ValueType::Pointer: {
				void* val = ret.Get<void*>();
				return PushLuaObject(val);
			}
			case ValueType::Float: {
				const float val = ret.Get<float>();
				return PushLuaObject(val);
			}
			case ValueType::Double: {
				const double val = ret.Get<double>();
				return PushLuaObject(val);
			}
			case ValueType::Function: {
				void* const val = ret.Get<void*>();
				return PushOrCreateFunctionObject(*retType.GetPrototype(), val);
			}
			case ValueType::String: {
				auto* const str = ret.Get<plg::string*>();
				return PushLuaObject(*str);
			}
			case ValueType::Any: {
				auto* const any = ret.Get<plg::any*>();
				return PushLuaObject(*any);
			}
			case ValueType::ArrayBool: {
				auto* const arr = ret.Get<plg::vector<bool>*>();
				return PushLuaObjectList<bool>(*arr);
			}
			case ValueType::ArrayChar8: {
				auto* const arr = ret.Get<plg::vector<char>*>();
				return PushLuaObjectList<char>(*arr);
			}
			case ValueType::ArrayChar16: {
				auto* const arr = ret.Get<plg::vector<char16_t>*>();
				return PushLuaObjectList<char16_t>(*arr);
			}
			case ValueType::ArrayInt8: {
				auto* const arr = ret.Get<plg::vector<int8_t>*>();
				return PushLuaObjectList<int8_t>(*arr);
			}
			case ValueType::ArrayInt16: {
				auto* const arr = ret.Get<plg::vector<int16_t>*>();
				return PushLuaObjectList<int16_t>(*arr);
			}
			case ValueType::ArrayInt32: {
				auto* const arr = ret.Get<plg::vector<int32_t>*>();
				return PushLuaObjectList<int32_t>(*arr);
			}
			case ValueType::ArrayInt64: {
				auto* const arr = ret.Get<plg::vector<int64_t>*>();
				return PushLuaObjectList<int64_t>(*arr);
			}
			case ValueType::ArrayUInt8: {
				auto* const arr = ret.Get<plg::vector<uint8_t>*>();
				return PushLuaObjectList<uint8_t>(*arr);
			}
			case ValueType::ArrayUInt16: {
				auto* const arr = ret.Get<plg::vector<uint16_t>*>();
				return PushLuaObjectList<uint16_t>(*arr);
			}
			case ValueType::ArrayUInt32: {
				auto* const arr = ret.Get<plg::vector<uint32_t>*>();
				return PushLuaObjectList<uint32_t>(*arr);
			}
			case ValueType::ArrayUInt64: {
				auto* const arr = ret.Get<plg::vector<uint64_t>*>();
				return PushLuaObjectList<uint64_t>(*arr);
			}
			case ValueType::ArrayPointer: {
				auto* const arr = ret.Get<plg::vector<void*>*>();
				return PushLuaObjectList<void*>(*arr);
			}
			case ValueType::ArrayFloat: {
				auto* const arr = ret.Get<plg::vector<float>*>();
				return PushLuaObjectList<float>(*arr);
			}
			case ValueType::ArrayDouble: {
				auto* const arr = ret.Get<plg::vector<double>*>();
				return PushLuaObjectList<double>(*arr);
			}
			case ValueType::ArrayString: {
				auto* const arr = ret.Get<plg::vector<plg::string>*>();
				return PushLuaObjectList<plg::string>(*arr);
			}
			case ValueType::ArrayAny: {
				auto* const arr = ret.Get<plg::vector<plg::any>*>();
				return PushLuaObjectList<plg::any>(*arr);
			}
			case ValueType::ArrayVector2: {
				auto* const arr = ret.Get<plg::vector<plg::vec2>*>();
				return PushLuaObjectList<plg::vec2>(*arr);
			}
			case ValueType::ArrayVector3: {
				auto* const arr = ret.Get<plg::vector<plg::vec3>*>();
				return PushLuaObjectList<plg::vec3>(*arr);
			}
			case ValueType::ArrayVector4: {
				auto* const arr = ret.Get<plg::vector<plg::vec4>*>();
				return PushLuaObjectList<plg::vec4>(*arr);
			}
			case ValueType::ArrayMatrix4x4: {
				auto* const arr = ret.Get<plg::vector<plg::mat4x4>*>();
				return PushLuaObjectList<plg::mat4x4>(*arr);
			}
			case ValueType::Vector2: {
				const plg::vec2 val = ret.Get<plg::vec2>();
				return PushLuaObject(val);
			}
			case ValueType::Vector3: {
				plg::vec3 val;
				if (ValueUtils::IsHiddenParam(retType.GetType())) {
					val = *ret.Get<plg::vec3*>();
				} else {
					val = ret.Get<plg::vec3>();
				}
				return PushLuaObject(val);
			}
			case ValueType::Vector4: {
				plg::vec4 val;
				if (ValueUtils::IsHiddenParam(retType.GetType())) {
					val = *ret.Get<plg::vec4*>();
				} else {
					val = ret.Get<plg::vec4>();
				}
				return PushLuaObject(val);
			}
			case ValueType::Matrix4x4: {
				plg::mat4x4 val = *ret.Get<plg::mat4x4*>();
				return PushLuaObject(val);
			}
			default:
				luaL_error(_L, "MakeExternalCallWithObject unsupported type %d", static_cast<int>(retType.GetType()));
				return false;
		}
	}

	bool LuaLanguageModule::PushObjectAsParam(const Property& paramType, int arg, ArgsScope& a) {
		const auto PushValParam = [&a](auto&& value) {
			if (!value) {
				return false;
			}
			a.params.Add(*value);
			return true;
		};
		const auto PushRefParam = [&paramType, &a](void* value) {
			if (!value) {
				return false;
			}
			a.storage.emplace_back(value, paramType.GetType());
			a.params.Add(value);
			return true;
		};

		switch (paramType.GetType()) {
			case ValueType::Bool:
				return PushValParam(ValueFromObject<bool>(arg));
			case ValueType::Char8:
				return PushValParam(ValueFromObject<char>(arg));
			case ValueType::Char16:
				return PushValParam(ValueFromObject<char16_t>(arg));
			case ValueType::Int8:
				return PushValParam(ValueFromObject<int8_t>(arg));
			case ValueType::Int16:
				return PushValParam(ValueFromObject<int16_t>(arg));
			case ValueType::Int32:
				return PushValParam(ValueFromObject<int32_t>(arg));
			case ValueType::Int64:
				return PushValParam(ValueFromObject<int64_t>(arg));
			case ValueType::UInt8:
				return PushValParam(ValueFromObject<uint8_t>(arg));
			case ValueType::UInt16:
				return PushValParam(ValueFromObject<uint16_t>(arg));
			case ValueType::UInt32:
				return PushValParam(ValueFromObject<uint32_t>(arg));
			case ValueType::UInt64:
				return PushValParam(ValueFromObject<uint64_t>(arg));
			case ValueType::Pointer:
				return PushValParam(ValueFromObject<void*>(arg));
			case ValueType::Float:
				return PushValParam(ValueFromObject<float>(arg));
			case ValueType::Double:
				return PushValParam(ValueFromObject<double>(arg));
			case ValueType::String:
				return PushRefParam(CreateValue<plg::string>(arg));
			case ValueType::Any:
				return PushRefParam(CreateValue<plg::any>(arg));
			case ValueType::Function:
				return PushValParam(GetOrCreateFunctionValue(*paramType.GetPrototype(), arg));
			case ValueType::ArrayBool:
				return PushRefParam(CreateArray<bool>(arg));
			case ValueType::ArrayChar8:
				return PushRefParam(CreateArray<char>(arg));
			case ValueType::ArrayChar16:
				return PushRefParam(CreateArray<char16_t>(arg));
			case ValueType::ArrayInt8:
				return PushRefParam(CreateArray<int8_t>(arg));
			case ValueType::ArrayInt16:
				return PushRefParam(CreateArray<int16_t>(arg));
			case ValueType::ArrayInt32:
				return PushRefParam(CreateArray<int32_t>(arg));
			case ValueType::ArrayInt64:
				return PushRefParam(CreateArray<int64_t>(arg));
			case ValueType::ArrayUInt8:
				return PushRefParam(CreateArray<uint8_t>(arg));
			case ValueType::ArrayUInt16:
				return PushRefParam(CreateArray<uint16_t>(arg));
			case ValueType::ArrayUInt32:
				return PushRefParam(CreateArray<uint32_t>(arg));
			case ValueType::ArrayUInt64:
				return PushRefParam(CreateArray<uint64_t>(arg));
			case ValueType::ArrayPointer:
				return PushRefParam(CreateArray<void*>(arg));
			case ValueType::ArrayFloat:
				return PushRefParam(CreateArray<float>(arg));
			case ValueType::ArrayDouble:
				return PushRefParam(CreateArray<double>(arg));
			case ValueType::ArrayString:
				return PushRefParam(CreateArray<plg::string>(arg));
			case ValueType::ArrayAny:
				return PushRefParam(CreateArray<plg::any>(arg));
			case ValueType::ArrayVector2:
				return PushRefParam(CreateArray<plg::vec2>(arg));
			case ValueType::ArrayVector3:
				return PushRefParam(CreateArray<plg::vec3>(arg));
			case ValueType::ArrayVector4:
				return PushRefParam(CreateArray<plg::vec4>(arg));
			case ValueType::ArrayMatrix4x4:
				return PushRefParam(CreateArray<plg::mat4x4>(arg));
			case ValueType::Vector2:
				return PushRefParam(CreateValue<plg::vec2>(arg));
			case ValueType::Vector3:
				return PushRefParam(CreateValue<plg::vec3>(arg));
			case ValueType::Vector4:
				return PushRefParam(CreateValue<plg::vec4>(arg));
			case ValueType::Matrix4x4:
				return PushRefParam(CreateValue<plg::mat4x4>(arg));
			default:
				luaL_error(_L, "PushObjectAsParam unsupported type %d", static_cast<int>(paramType.GetType()));
				return {};
		}
	}

	bool LuaLanguageModule::PushObjectAsRefParam(const Property& paramType, int arg, ArgsScope& a) {
		const auto PushRefParam = [&paramType, &a](void* value) {
			if (!value) {
				return false;
			}
			a.storage.emplace_back(value, paramType.GetType());
			a.params.Add(value);
			return true;
		};

		switch (paramType.GetType()) {
			case ValueType::Bool:
				return PushRefParam(CreateValue<bool>(arg));
			case ValueType::Char8:
				return PushRefParam(CreateValue<char>(arg));
			case ValueType::Char16:
				return PushRefParam(CreateValue<char16_t>(arg));
			case ValueType::Int8:
				return PushRefParam(CreateValue<int8_t>(arg));
			case ValueType::Int16:
				return PushRefParam(CreateValue<int16_t>(arg));
			case ValueType::Int32:
				return PushRefParam(CreateValue<int32_t>(arg));
			case ValueType::Int64:
				return PushRefParam(CreateValue<int64_t>(arg));
			case ValueType::UInt8:
				return PushRefParam(CreateValue<uint8_t>(arg));
			case ValueType::UInt16:
				return PushRefParam(CreateValue<uint16_t>(arg));
			case ValueType::UInt32:
				return PushRefParam(CreateValue<uint32_t>(arg));
			case ValueType::UInt64:
				return PushRefParam(CreateValue<uint64_t>(arg));
			case ValueType::Pointer:
				return PushRefParam(CreateValue<void*>(arg));
			case ValueType::Float:
				return PushRefParam(CreateValue<float>(arg));
			case ValueType::Double:
				return PushRefParam(CreateValue<double>(arg));
			case ValueType::String:
				return PushRefParam(CreateValue<plg::string>(arg));
			case ValueType::Any:
				return PushRefParam(CreateValue<plg::any>(arg));
			case ValueType::ArrayBool:
				return PushRefParam(CreateArray<bool>(arg));
			case ValueType::ArrayChar8:
				return PushRefParam(CreateArray<char>(arg));
			case ValueType::ArrayChar16:
				return PushRefParam(CreateArray<char16_t>(arg));
			case ValueType::ArrayInt8:
				return PushRefParam(CreateArray<int8_t>(arg));
			case ValueType::ArrayInt16:
				return PushRefParam(CreateArray<int16_t>(arg));
			case ValueType::ArrayInt32:
				return PushRefParam(CreateArray<int32_t>(arg));
			case ValueType::ArrayInt64:
				return PushRefParam(CreateArray<int64_t>(arg));
			case ValueType::ArrayUInt8:
				return PushRefParam(CreateArray<uint8_t>(arg));
			case ValueType::ArrayUInt16:
				return PushRefParam(CreateArray<uint16_t>(arg));
			case ValueType::ArrayUInt32:
				return PushRefParam(CreateArray<uint32_t>(arg));
			case ValueType::ArrayUInt64:
				return PushRefParam(CreateArray<uint64_t>(arg));
			case ValueType::ArrayPointer:
				return PushRefParam(CreateArray<void*>(arg));
			case ValueType::ArrayFloat:
				return PushRefParam(CreateArray<float>(arg));
			case ValueType::ArrayDouble:
				return PushRefParam(CreateArray<double>(arg));
			case ValueType::ArrayString:
				return PushRefParam(CreateArray<plg::string>(arg));
			case ValueType::ArrayAny:
				return PushRefParam(CreateArray<plg::any>(arg));
			case ValueType::ArrayVector2:
				return PushRefParam(CreateArray<plg::vec2>(arg));
			case ValueType::ArrayVector3:
				return PushRefParam(CreateArray<plg::vec3>(arg));
			case ValueType::ArrayVector4:
				return PushRefParam(CreateArray<plg::vec4>(arg));
			case ValueType::ArrayMatrix4x4:
				return PushRefParam(CreateArray<plg::mat4x4>(arg));
			case ValueType::Vector2:
				return PushRefParam(CreateValue<plg::vec2>(arg));
			case ValueType::Vector3:
				return PushRefParam(CreateValue<plg::vec3>(arg));
			case ValueType::Vector4:
				return PushRefParam(CreateValue<plg::vec4>(arg));
			case ValueType::Matrix4x4:
				return PushRefParam(CreateValue<plg::mat4x4>(arg));
			default:
				luaL_error(_L, "PushObjectAsRefParam unsupported enum type %d", static_cast<int>(paramType.GetType()));
				return {};
		}
	}

	bool LuaLanguageModule::StorageValueToObject(const Property& paramType, const ArgsScope& a, size_t index) {
		switch (paramType.GetType()) {
			case ValueType::Bool:
				return PushLuaObject(*static_cast<bool*>(std::get<0>(a.storage[index])));
			case ValueType::Char8:
				return PushLuaObject(*static_cast<char*>(std::get<0>(a.storage[index])));
			case ValueType::Char16:
				return PushLuaObject(*static_cast<char16_t*>(std::get<0>(a.storage[index])));
			case ValueType::Int8:
				return PushLuaObject(*static_cast<int8_t*>(std::get<0>(a.storage[index])));
			case ValueType::Int16:
				return PushLuaObject(*static_cast<int16_t*>(std::get<0>(a.storage[index])));
			case ValueType::Int32:
				return PushLuaObject(*static_cast<int32_t*>(std::get<0>(a.storage[index])));
			case ValueType::Int64:
				return PushLuaObject(*static_cast<int64_t*>(std::get<0>(a.storage[index])));
			case ValueType::UInt8:
				return PushLuaObject(*static_cast<uint8_t*>(std::get<0>(a.storage[index])));
			case ValueType::UInt16:
				return PushLuaObject(*static_cast<uint16_t*>(std::get<0>(a.storage[index])));
			case ValueType::UInt32:
				return PushLuaObject(*static_cast<uint32_t*>(std::get<0>(a.storage[index])));
			case ValueType::UInt64:
				return PushLuaObject(*static_cast<uint64_t*>(std::get<0>(a.storage[index])));
			case ValueType::Float:
				return PushLuaObject(*static_cast<float*>(std::get<0>(a.storage[index])));
			case ValueType::Double:
				return PushLuaObject(*static_cast<double*>(std::get<0>(a.storage[index])));
			case ValueType::String:
				return PushLuaObject(*static_cast<plg::string*>(std::get<0>(a.storage[index])));
			case ValueType::Any:
				return PushLuaObject(*static_cast<plg::any*>(std::get<0>(a.storage[index])));
			case ValueType::Pointer:
				return PushLuaObject(*static_cast<void**>(std::get<0>(a.storage[index])));
			case ValueType::ArrayBool:
				return PushLuaObjectList(*static_cast<plg::vector<bool>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayChar8:
				return PushLuaObjectList(*static_cast<plg::vector<char>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayChar16:
				return PushLuaObjectList(*static_cast<plg::vector<char16_t>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayInt8:
				return PushLuaObjectList(*static_cast<plg::vector<int8_t>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayInt16:
				return PushLuaObjectList(*static_cast<plg::vector<int16_t>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayInt32:
				return PushLuaObjectList(*static_cast<plg::vector<int32_t>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayInt64:
				return PushLuaObjectList(*static_cast<plg::vector<int64_t>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayUInt8:
				return PushLuaObjectList(*static_cast<plg::vector<uint8_t>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayUInt16:
				return PushLuaObjectList(*static_cast<plg::vector<uint16_t>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayUInt32:
				return PushLuaObjectList(*static_cast<plg::vector<uint32_t>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayUInt64:
				return PushLuaObjectList(*static_cast<plg::vector<uint64_t>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayPointer:
				return PushLuaObjectList(*static_cast<plg::vector<void*>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayFloat:
				return PushLuaObjectList(*static_cast<plg::vector<float>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayDouble:
				return PushLuaObjectList(*static_cast<plg::vector<double>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayString:
				return PushLuaObjectList(*static_cast<plg::vector<plg::string>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayAny:
				return PushLuaObjectList(*static_cast<plg::vector<plg::any>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayVector2:
				return PushLuaObjectList(*static_cast<plg::vector<plg::vec2>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayVector3:
				return PushLuaObjectList(*static_cast<plg::vector<plg::vec3>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayVector4:
				return PushLuaObjectList(*static_cast<plg::vector<plg::vec4>*>(std::get<0>(a.storage[index])));
			case ValueType::ArrayMatrix4x4:
				return PushLuaObjectList(*static_cast<plg::vector<plg::mat4x4>*>(std::get<0>(a.storage[index])));
			case ValueType::Vector2:
				return PushLuaObject(*static_cast<plg::vec2*>(std::get<0>(a.storage[index])));
			case ValueType::Vector3:
				return PushLuaObject(*static_cast<plg::vec3*>(std::get<0>(a.storage[index])));
			case ValueType::Vector4:
				return PushLuaObject(*static_cast<plg::vec4*>(std::get<0>(a.storage[index])));
			case ValueType::Matrix4x4:
				return PushLuaObject(*static_cast<plg::mat4x4*>(std::get<0>(a.storage[index])));
			default:
				luaL_error(_L, "StorageValueToObject unsupported type %d", static_cast<int>(paramType.GetType()));
				return false;
		}
	}

	void LuaLanguageModule::ExternalCall(const Method& method, MemAddr data, uint64_t* parameters, size_t count, void* return_) {
		ParametersSpan params(parameters, count);
		ReturnSlot ret(return_, ValueUtils::SizeOf(ValueType::Int32));

		// int (MethodLuaCall*)(lua_State* L)
		assert(params.Get<lua_State*>(0) == _L);

		const auto& paramTypes = method.GetParamTypes();
		const size_t paramCount = paramTypes.size();
		const auto size = static_cast<size_t>(lua_gettop(_L));
		const size_t t = size - paramCount;
		if (t == 0 && size != paramCount) {
			luaL_error(_L, "Wrong number of parameters, %zu when %zu required.", size, paramCount);
			ret.Set<int>(0);
			return;
		}

		const auto& retType = method.GetRetType();
		const bool hasHiddenParam = ValueUtils::IsHiddenParam(retType.GetType());
		int refParamsCount = 0;

		ArgsScope a(hasHiddenParam + paramCount);
		Return r;

		if (hasHiddenParam) {
			BeginExternalCall(retType.GetType(), a);
		}

		for (size_t i = 0; i < paramCount; ++i) {
			const Property& paramType = paramTypes[i];
			if (paramType.IsRef()) {
				++refParamsCount;
			}
			using PushParamFunc = decltype(&LuaLanguageModule::PushObjectAsParam);
			PushParamFunc const pushParamFunc = paramType.IsRef() ? &LuaLanguageModule::PushObjectAsRefParam : &LuaLanguageModule::PushObjectAsParam;
			const bool pushResult = (this->*pushParamFunc)(paramType, static_cast<int>(i + 1 + t), a);
			if (!pushResult) {
				// pushParamFunc sets error
				ret.Set<int>(static_cast<int>(i + 1));
				return;
			}
		}

		bool result = MakeExternalCallWithObject(retType, data.RCast<JitCall::CallingFunc>(), a, r); // TODO: not push nil when void and no param

		if (refParamsCount != 0) {
			int k = 0;

			for (size_t i = 0, j = hasHiddenParam; i < paramCount; ++i) {
				const Property& paramType = paramTypes[i];
				if (!paramType.IsRef()) {
					continue;
				}
				StorageValueToObject(paramType, a, j++);
				if (++k == refParamsCount) {
					break;
				}
			}
		}

		ret.Set<int>(refParamsCount + result);
	}

#pragma endregion ExternalCall

	void LuaLanguageModule::ResolveRequiredModule(std::string_view moduleName) {
		const auto* plugin = _provider->FindExtension(moduleName);
		if (plugin && plugin->GetState() == ExtensionState::Loaded) {
			TryCreateModule(*plugin, false);
		} else {
			luaL_requiref(_L, moduleName.data(), &LoadEmpty, 1);
			lua_pop(_L, 1);
		}
	}

	void LuaLanguageModule::CreateEnumObject(LuaEnumSet& enumSet, const Property& paramType) {
		if (const auto prototype = paramType.GetPrototype()) {
			CreateEnumObject(enumSet, *prototype);
		}

		const auto enumerator = paramType.GetEnumerate();
		if (!enumerator) {
			return;
		}

		const auto& enumName = enumerator->GetName();
		const auto& enumValues = enumerator->GetValues();
		if (enumSet.contains(enumName) || enumValues.empty()) {
			return;
		}

		lua_newtable(_L);

		for (const auto& enumValue : enumValues) {
			lua_pushinteger(_L, enumValue.GetValue());
			lua_setfield(_L, -2, enumValue.GetName().data());
		}

		lua_setfield(_L, -2, enumName.data());

		enumSet.emplace(enumName);
	}

	void LuaLanguageModule::CreateEnumObject(LuaEnumSet& enumSet, const Method& method) {
		CreateEnumObject(enumSet, method.GetRetType());
		for (const auto& paramType : method.GetParamTypes()) {
			CreateEnumObject(enumSet, paramType);
		}
	}

	bool LuaLanguageModule::PushInvalidValue(ValueType handleType, std::string_view invalidValue) {
		if (!invalidValue.empty()) {
			// Single numeric parse path
			auto parseInteger = [&]() -> std::optional<int64_t> {
				return plg::cast_to<int64_t>(invalidValue);
			};
			auto parseFloat = [&]() -> std::optional<double> {
				return plg::cast_to<double>(invalidValue);
			};

			const bool isFloat = invalidValue.contains('.') ||
								 handleType == ValueType::Float ||
								 handleType == ValueType::Double;

			if (isFloat) {
				if (auto v = parseFloat()) return PushLuaObject(*v);
			} else {
				if (auto v = parseInteger()) return PushLuaObject(*v);
			}

			return PushLuaObject(invalidValue);
		}

		switch (handleType) {
			case ValueType::Bool:      return PushLuaObject(false);
			case ValueType::Int8:      return PushLuaObject(int8_t{0});
			case ValueType::Int16:     return PushLuaObject(int16_t{0});
			case ValueType::Int32:     return PushLuaObject(int32_t{0});
			case ValueType::Int64:     return PushLuaObject(int64_t{0});
			case ValueType::UInt8:     return PushLuaObject(uint8_t{0});
			case ValueType::UInt16:    return PushLuaObject(uint16_t{0});
			case ValueType::UInt32:    return PushLuaObject(uint32_t{0});
			case ValueType::UInt64:    return PushLuaObject(uint64_t{0});
			case ValueType::Float:     return PushLuaObject(float{0});
			case ValueType::Double:    return PushLuaObject(double{0});
			case ValueType::Pointer:   return PushLuaObject(static_cast<void*>(nullptr));
			case ValueType::String:    return PushLuaObject(std::string_view(""));
			default:                   return PushLuaObject();
		}
	}

	bool LuaLanguageModule::PushAliasObject(const Alias& alias) {
		if (alias.GetName().empty()) {
			lua_pushnil(_L);
			return false;
		}

		lua_createtable(_L, 2, 0);

		// [1] = name
		PushLuaObject(alias.GetName());
		lua_rawseti(_L, -2, 1);

		// [2] = owner
		PushLuaObject(alias.IsOwner());
		lua_rawseti(_L, -2, 2);

		return true;
	}

	bool LuaLanguageModule::PushBindingObject(const LuaFunctionMap& functions, const Binding& binding) {
		lua_createtable(_L, 5, 0);

		// [1] = name
		PushLuaObject(binding.GetName());
		lua_rawseti(_L, -2, 1);

		// [2] = func
		auto it = functions.find(binding.GetMethod());
		if (it != functions.end()) {
			lua_pushcfunction(_L, it->second);
		} else {
			_provider->Log(std::format(LOG_PREFIX "Method function not found: {}", binding.GetMethod()), Severity::Fatal);
			std::terminate();
		}
		lua_rawseti(_L, -2, 2);

		// [3] = bindSelf
		PushLuaObject(binding.IsBindSelf());
		lua_rawseti(_L, -2, 3);

		// [4] = paramAliases (array of Alias or nil)
		const auto& paramAliases = binding.GetParamAliases();
		lua_createtable(_L, static_cast<int>(paramAliases.size()), 0);
		for (size_t j = 0; j < paramAliases.size(); ++j) {
			PushAliasObject(paramAliases[j]);
			lua_rawseti(_L, -2, static_cast<int>(j + 1));
		}
		lua_rawseti(_L, -2, 4);

		// [5] = retAlias (Alias or nil)
		PushAliasObject(binding.GetRetAlias());
		lua_rawseti(_L, -2, 5);

		return true;
	}

	void LuaLanguageModule::CreateClassObject(const LuaFunctionMap& functions, const Class& cls) {
		const std::string& className = cls.GetName();

		// Create class table
		lua_newtable(_L);
		PushLuaObject(className);
		lua_setfield(_L, -2, "__type");
		int cls_table_idx = lua_gettop(_L);

		// Call bind_class_methods(cls, constructors, destructor, methods, invalid_value)
		lua_rawgeti(_L, LUA_REGISTRYINDEX, _bindClassFunc);

		// Arg 1: cls (the class table)
		lua_pushvalue(_L, cls_table_idx);

		// Arg 2: constructors (array of functions)
		const auto& constructors = cls.GetConstructors();
		lua_createtable(_L, static_cast<int>(constructors.size()), 0);
		for (size_t i = 0; i < constructors.size(); ++i) {
			auto it = functions.find(constructors[i]);
			if (it != functions.end()) {
				lua_pushcfunction(_L, it->second);
				lua_rawseti(_L, -2, static_cast<int>(i + 1));
			} else {
				_provider->Log(std::format(LOG_PREFIX "Constructor function not found: {}", constructors[i]), Severity::Fatal);
				std::terminate();
			}
		}

		// Arg 3: destructor (function or nil)
		const std::string& destructor = cls.GetDestructor();
		if (!destructor.empty()) {
			auto it = functions.find(destructor);
			if (it != functions.end()) {
				lua_pushcfunction(_L, it->second);
			} else {
				_provider->Log(std::format(LOG_PREFIX "Destructor function not found: {}", destructor), Severity::Fatal);
				std::terminate();
			}
		} else {
			lua_pushnil(_L);
		}

		// Arg 4: methods (array of {name, func, bindSelf, paramAliases, retAlias})
		const auto& bindings = cls.GetBindings();
		lua_createtable(_L, static_cast<int>(bindings.size()), 0);
		for (size_t i = 0; i < bindings.size(); ++i) {
			PushBindingObject(functions, bindings[i]);
			lua_rawseti(_L, -2, static_cast<int>(i + 1));
		}

		// Arg 5: invalid_value
		PushInvalidValue(cls.GetHandleType(), cls.GetInvalidValue());

		// Call: bind_class_methods(cls, constructors, destructor, methods, invalid_value)
		if (lua_pcall(_L, 5, 1, 0) != LUA_OK) {
			LogError();
			_provider->Log(std::format(LOG_PREFIX "{}: call of 'bind_class_methods' failed", className), Severity::Error);
			lua_pop(_L, 1);
			lua_pop(_L, 1); // Pop class table
			return;
		}

		// Stack: [module_table, cls_table, result]
		// Remove cls_table and set result in module_table
		lua_remove(_L, -2); // Stack: [module_table, result]
		lua_setfield(_L, -2, className.data()); // module_table[className] = result
	}

	LuaFunctionMap LuaLanguageModule::CreateFunctions(const Extension& plugin) {
		const auto& methods = plugin.GetMethodsData();

		LuaFunctionMap funcs;
		funcs.reserve(methods.size());

		for (const auto& [method, addr] : methods) {
			JitCall call{};

			const MemAddr callAddr = call.GetJitFunc(method, addr);
			if (!callAddr) {
				_provider->Log(std::format(LOG_PREFIX "Lang module JIT failed to generate c++ call wrapper '{}'", call.GetError()), Severity::Fatal);
				std::terminate();
			}

			JitCallback callback{};

			Signature sig{};
			sig.AddArg(ValueType::Pointer);
			sig.SetRet(ValueType::Int32);

			// Generate function --> int (MethodLuaCall*)(lua_State* L)
			const MemAddr methodAddr = callback.GetJitFunc(sig, &method, &detail::ExternalCall, callAddr, false);
			if (!methodAddr) {
				_provider->Log(std::format(LOG_PREFIX "Lang module JIT failed to generate c++ lua_CFunction wrapper '{}'", callback.GetError()), Severity::Fatal);
				std::terminate();
			}

			_moduleFunctions.emplace_back(std::move(callback), std::move(call));

			funcs.emplace(method.GetName(), methodAddr.RCast<lua_CFunction>());
		}

		return funcs;
	}

	lua_CFunction LuaLanguageModule::OpenModule(std::string filename) {
		filename.reserve(sizeof(std::string)); // disable SSO

		JitCallback callback{};

		Signature sig{};
		sig.AddArg(ValueType::Pointer);
		sig.SetRet(ValueType::Int32);

		// Generate function --> int (MethodLuaCall*)(lua_State* L)
		const MemAddr methodAddr = callback.GetJitFunc(sig, nullptr, &LoadFile, filename.c_str(), false);
		if (methodAddr) {
			_loadFunctions.emplace_back(std::move(callback), std::move(filename));
		}
		return methodAddr.RCast<lua_CFunction>();
	}

	Result<InitData> LuaLanguageModule::Initialize(const Provider& provider, const Extension& module) {
		_provider = std::make_unique<Provider>(provider);

		std::error_code ec;
		const fs::path moduleBasePath = fs::absolute(module.GetLocation(), ec);
		if (ec) {
			return MakeError("Failed to get module directory path");
		}

		const fs::path libPath = moduleBasePath / "lib";
		if (!fs::exists(libPath, ec) || !fs::is_directory(libPath, ec)) {
			return MakeError("lib directory not exists");
		}

		_L = luaL_newstate();
		luaL_openlibs(_L);

		for (const auto& entry : fs::directory_iterator(libPath)) {
			if (entry.is_regular_file() && entry.path().extension() == ".lua") {
				const std::string& filename = plg::as_string(entry.path().filename().replace_extension());
				luaL_requiref(_L, filename.c_str(), OpenModule(plg::as_string(entry.path())), 0);
				lua_pop(_L, 1);
			}
		}

		// Save original require
		lua_getglobal(_L, "require");
		_originalRequireRef = luaL_ref(_L, LUA_REGISTRYINDEX);

		// Register our custom require
		lua_pushcfunction(_L, CustomRequire);
		lua_setglobal(_L, "require");

		lua_getglobal(_L, "package"); // Stack: package
		lua_getfield(_L, -1, "loaded"); // Stack: package, loaded
		lua_getfield(_L, -1, "plugify"); // Stack: package, loaded, plugify

		lua_getfield(_L, -1, "bind_class_methods");
		if (!lua_isfunction(_L, -1)) {
			lua_pop(_L, 4);
			return MakeError("bind_class_methods is not a function");
		}

		// Stack: package, loaded, bind_class_methods
		_bindClassFunc = luaL_ref(_L, LUA_REGISTRYINDEX); // Store bind_class_methods instance

		lua_getfield(_L, -1, "Vector2"); // Stack: package, loaded, plugify, Vector2
		lua_getfield(_L, -1, "new"); // Stack: package, loaded, plugify, Vector2, Vector2.new

		// Stack: package, loaded, Vector2, vector2_instance
		_vector2Ref = luaL_ref(_L, LUA_REGISTRYINDEX); // Store Vector2 instance
		lua_pop(_L, 1);

		lua_getfield(_L, -1, "Vector3"); // Stack: package, loaded, plugify, Vector3
		lua_getfield(_L, -1, "new"); // Stack: package, loaded, plugify, Vector3, Vector3.new

		// Stack: package, loaded, Vector3, vector3_instance
		_vector3Ref = luaL_ref(_L, LUA_REGISTRYINDEX); // Store Vector3 instance
		lua_pop(_L, 1);

		lua_getfield(_L, -1, "Vector4"); // Stack: package, loaded, plugify, Vector4
		lua_getfield(_L, -1, "new"); // Stack: package, loaded, plugify, Vector4, Vector4.new

		// Stack: package, loaded, Vector4, vector4_instance
		_vector4Ref = luaL_ref(_L, LUA_REGISTRYINDEX); // Store Vector2 instance
		lua_pop(_L, 1);

		lua_getfield(_L, -1, "Matrix4x4"); // Stack: package, loaded, plugify, Matrix4x4
		lua_getfield(_L, -1, "new"); // Stack: package, loaded, plugify, Matrix4x4, Matrix4x4.new

		// Stack: package, loaded, Matrix4x4, matrix4x4_instance
		_matrix4x4Ref = luaL_ref(_L, LUA_REGISTRYINDEX); // Store Matrix4x4 instance
		lua_pop(_L, 1);

		lua_pop(_L, 3); // Pop plugify, loaded, package

		return InitData{{.hasUpdate = false}};
	}

	void LuaLanguageModule::Shutdown() {
		lua_rawgeti(_L, LUA_REGISTRYINDEX, _originalRequireRef);
		lua_setglobal(_L, "require");

		luaL_unref(_L, LUA_REGISTRYINDEX, _originalRequireRef);
		_originalRequireRef = LUA_NOREF;
		luaL_unref(_L, LUA_REGISTRYINDEX, _bindClassFunc);
		_bindClassFunc = LUA_NOREF;
		luaL_unref(_L, LUA_REGISTRYINDEX, _vector2Ref);
		_vector2Ref = LUA_NOREF;
		luaL_unref(_L, LUA_REGISTRYINDEX, _vector3Ref);
		_vector3Ref = LUA_NOREF;
		luaL_unref(_L, LUA_REGISTRYINDEX, _vector4Ref);
		_vector4Ref = LUA_NOREF;
		luaL_unref(_L, LUA_REGISTRYINDEX, _matrix4x4Ref);
		_matrix4x4Ref = LUA_NOREF;

		for (const auto& [_, data] : _pluginsMap) {
			const auto& [instance, update, start, end] = data;
			luaL_unref(_L, LUA_REGISTRYINDEX, update);
			luaL_unref(_L, LUA_REGISTRYINDEX, start);
			luaL_unref(_L, LUA_REGISTRYINDEX, end);
		}
		_pluginsMap.clear();
		_internalMap.clear();
		_externalMap.clear();
		_internalFunctions.clear();
		_externalFunctions.clear();

		for (const auto& [_, data] : _luaMethods) {
			const auto& [plugin, method] = *data;
			luaL_unref(_L, LUA_REGISTRYINDEX, method);
			luaL_unref(_L, LUA_REGISTRYINDEX, plugin);
		}
		_luaMethods.clear();
		_moduleFunctions.clear();
		_loadFunctions.clear();

		lua_close(_L);
		_L = nullptr;
	}

	void LuaLanguageModule::OnUpdate([[maybe_unused]] std::chrono::milliseconds dt) {
	}

	Result<LoadData> LuaLanguageModule::OnPluginLoad(const Extension& plugin) {
		const std::string_view entryPoint = plugin.GetEntry();
		if (entryPoint.empty()) {
			return MakeError("Incorrect entry point: empty");
		}
		if (entryPoint.find_first_of("/\\") != std::string::npos) {
			return MakeError("Incorrect entry point: contains '/' or '\\'");
		}
		const std::string::size_type lastDotPos = entryPoint.find_last_of('.');
		if (lastDotPos == std::string::npos) {
			return MakeError("Incorrect entry point: not have any dot '.' character");
		}
		std::string_view pluginClassName(entryPoint.begin() + static_cast<ptrdiff_t>(lastDotPos + 1), entryPoint.end());
		if (pluginClassName.empty()) {
			return MakeError("Incorrect entry point: empty class name part");
		}
		std::string_view modulePathRel(entryPoint.begin(), entryPoint.begin() + static_cast<ptrdiff_t>(lastDotPos));
		if (modulePathRel.empty()) {
			return MakeError("Incorrect entry point: empty module path part");
		}

		const fs::path& baseFolder = plugin.GetLocation();
		std::string modulePath(modulePathRel);

		ReplaceAll(modulePath, ".", { static_cast<char>(fs::path::preferred_separator) });
		fs::path filePathRelative = modulePath;
		filePathRelative.replace_extension(".lua");
		const fs::path filePath = baseFolder / filePathRelative;
		std::error_code ec;
		if (!fs::exists(filePath, ec) || !fs::is_regular_file(filePath, ec)) {
			return MakeError("Module file '{}' not exist", plg::as_string(filePath));
		}
		const std::string& fileName = plg::as_string(filePath.filename().replace_extension());

		luaL_requiref(_L, fileName.c_str(), OpenModule(plg::as_string(filePath)), 0);
		lua_pop(_L, 1);

		lua_getglobal(_L, "package"); // Stack: package
		lua_getfield(_L, -1, "loaded"); // Stack: package, loaded
		lua_getfield(_L, -1, fileName.c_str()); // Stack: package, loaded, plugin
		if (!lua_istable(_L, -1)) {
			lua_pop(_L, 3); // Pop plugin, loaded, package
			return MakeError("Failed to find table");
		}

		lua_getfield(_L, -1, pluginClassName.data()); // Stack: package, loaded, plugin, Plugin
		if (!lua_istable(_L, -1)) {
			lua_pop(_L, 4); // Pop Plugin, plugin, loaded, package
			return MakeError("Failed to find plugin class");
		}

		// Get Plugin:new
		lua_getfield(_L, -1, "new"); // Stack: ..., Plugin, Plugin.new
		if (!lua_isfunction(_L, -1)) {
			lua_pop(_L, 5); // Pop new, Plugin, plugin, loaded, package
			return MakeError("Failed to find plugin constructor");
		}

		const auto& dependencies = plugin.GetDependencies();

		plg::vector<std::string_view> deps;
		deps.reserve(dependencies.size());
		for (const auto& dependency : dependencies) {
			deps.emplace_back(dependency.GetName());
		}

		// Push arguments for Plugin:new
		lua_pushvalue(_L, -2); // self (Plugin)
		PushLuaObject(static_cast<int64_t>(plugin.GetId())); // id
		PushLuaObject(plugin.GetName()); // name
		PushLuaObject(plugin.GetDescription()); // description
		PushLuaObject(plugin.GetVersionString()); // version
		PushLuaObject(plugin.GetAuthor()); // author
		PushLuaObject(plugin.GetWebsite()); // website
		PushLuaObject(plugin.GetLicense()); // license
		PushLuaObject(plugin.GetLocation()); // location
		PushLuaObjectList(deps); // dependencies

		PushLuaObject(_provider->GetBaseDir()); // base_dir
		PushLuaObject(_provider->GetExtensionsDir()); // extensions_dir
		PushLuaObject(_provider->GetConfigsDir()); // configs_dir
		PushLuaObject(_provider->GetDataDir()); // data_dir
		PushLuaObject(_provider->GetLogsDir()); // logs_dir
		PushLuaObject(_provider->GetCacheDir()); // cache_dir
		if (lua_pcall(_L, 16, 1, 0) != LUA_OK) {
			std::string errorString = std::format("Failed to create plugin instance: {}", lua_tostring(_L, -1));
			lua_pop(_L, 5); // Pop error, Plugin, plugin, loaded, package
			return MakeError(std::move(errorString));
		}

		// Store references to plugin_start, plugin_end, plugin_update (if they exist)
		int pluginStart = LUA_NOREF;
		int pluginUpdate = LUA_NOREF;
		int pluginEnd = LUA_NOREF;

		lua_getfield(_L, -1, "plugin_start"); // Stack: ..., instance, plugin_start or nil
		if (!lua_isnil(_L, -1)) {
			pluginStart = luaL_ref(_L, LUA_REGISTRYINDEX); // Store plugin_start
		} else {
			lua_pop(_L, 1); // Pop nil
		}
		lua_getfield(_L, -1, "plugin_update"); // Stack: ..., instance, plugin_update or nil
		if (!lua_isnil(_L, -1)) {
			pluginUpdate = luaL_ref(_L, LUA_REGISTRYINDEX); // Store plugin_update
		} else {
			lua_pop(_L, 1); // Pop nil
		}
		lua_getfield(_L, -1, "plugin_end"); // Stack: ..., instance, plugin_end or nil
		if (!lua_isnil(_L, -1)) {
			pluginEnd = luaL_ref(_L, LUA_REGISTRYINDEX); // Store plugin_end
		} else {
			lua_pop(_L, 1); // Pop nil
		}

		// Stack: package, loaded, plugin, Plugin, instance
		int pluginRef = luaL_ref(_L, LUA_REGISTRYINDEX); // Store instance
		lua_pop(_L, 1); // Pop Plugin

		const auto& exportedMethods = plugin.GetMethods();
		std::vector<std::string> exportErrors;
		std::vector<std::pair<const Method&, LuaMethodData>> methodsHolders;

		for (size_t i = 0; i < exportedMethods.size(); ++i) {
			const auto& method = exportedMethods[i];
			Result<LuaMethodData> generateResult = GenerateMethodExport(method, pluginRef);
			if (!generateResult) {
				exportErrors.emplace_back(std::format("{:>3}. {} {}", i + 1, method.GetName(), generateResult.error()));
				if (constexpr size_t kMaxDisplay = 100; exportErrors.size() >= kMaxDisplay) {
					exportErrors.emplace_back(std::format("... and {} more", exportedMethods.size() - kMaxDisplay));
					break;
				}
				continue;
			}
			methodsHolders.emplace_back(method, std::move(*generateResult));
		}

		lua_pop(_L, 3); // Pop plugin, loaded, package

		if (!exportErrors.empty()) {
			return MakeError("Invalid methods:\n{}", plg::join(exportErrors, "\n"));
		}

		const auto [it, result] = _pluginsMap.try_emplace(
				plugin.GetId(),
				pluginRef,
				pluginUpdate,
				pluginStart,
				pluginEnd);
		if (!result) {
			return MakeError("Save plugin data to map unsuccessful");
		}

		std::vector<MethodData> methods;
		methods.reserve(methodsHolders.size());
		_luaMethods.reserve(methodsHolders.size());

		for (auto& [method, methodData] : methodsHolders) {
			const MemAddr methodAddr = methodData.jitCallback.GetFunction();
			methods.emplace_back(method, methodAddr);
			AddToFunctionsMap(methodAddr, *methodData.luaFunction);
			_luaMethods.emplace_back(std::move(methodData));
		}
		return LoadData{ std::move(methods), &it->second, { pluginUpdate != LUA_NOREF, pluginStart != LUA_NOREF, pluginEnd != LUA_NOREF, !exportedMethods.empty() }};
	}

	void LuaLanguageModule::AddToFunctionsMap(void* funcAddr, LuaFunction funcObj) {
		_externalMap.emplace(funcAddr, funcObj);
		_internalMap.emplace(funcObj, funcAddr);
	}

	LuaFunction LuaLanguageModule::FindExternal(void* funcAddr) const {
		const auto it = _externalMap.find(funcAddr);
		if (it != _externalMap.end()) {
			return std::get<LuaFunction>(*it);
		}
		return {LUA_NOREF, LUA_NOREF};
	}

	void* LuaLanguageModule::FindInternal(LuaFunction funcObj) const {
		const auto it = _internalMap.find(funcObj);
		if (it != _internalMap.end()) {
			return std::get<void*>(*it);
		}
		return nullptr;
	}

	void LuaLanguageModule::LogError() {
		std::string trace = std::format(LOG_PREFIX "{}\nstack traceback:\n", lua_tostring(_L, -1));
		lua_Debug ar;
		for (int level = 0; lua_getstack(_L, level, &ar); ++level) {
			lua_getinfo(_L, "Sln", &ar);
			std::format_to(std::back_inserter(trace), "\t{}:{}: in function '{}'\n", ar.short_src, ar.currentline, ar.name ? ar.name : "?");
		}
		_provider->Log(trace, Severity::Error);
	}

	void LuaLanguageModule::OnPluginStart(const Extension& plugin) {
		const auto& [instance, update, start, end] = *plugin.GetUserData().RCast<PluginData*>();
		if (start != LUA_NOREF) {
			lua_rawgeti(_L, LUA_REGISTRYINDEX, instance); // Stack: instance
			lua_rawgeti(_L, LUA_REGISTRYINDEX, start); // Stack: instance, plugin_start
			lua_pushvalue(_L, -2); // self
			if (lua_pcall(_L, 1, 0, 0) != LUA_OK) {
				LogError();
				_provider->Log(std::format(LOG_PREFIX "{}: call of 'plugin_start' failed", plugin.GetName()), Severity::Error);
				lua_pop(_L, 1); // Pop error
			}
			lua_pop(_L, 1); // Pop instance
		}
	}

	void LuaLanguageModule::OnPluginUpdate(const Extension& plugin, std::chrono::milliseconds dt) {
		const auto& [instance, update, start, end] = *plugin.GetUserData().RCast<PluginData*>();
		if (update != LUA_NOREF) {
			lua_rawgeti(_L, LUA_REGISTRYINDEX, instance); // Stack: instance
			lua_rawgeti(_L, LUA_REGISTRYINDEX, update); // Stack: instance, plugin_update
			lua_pushvalue(_L, -2); // self
			lua_pushnumber(_L, std::chrono::duration<float>(dt).count()); // dt
			if (lua_pcall(_L, 2, 0, 0) != LUA_OK) {
				LogError();
				_provider->Log(std::format(LOG_PREFIX "{}: call of 'plugin_update' failed", plugin.GetName()), Severity::Error);
				lua_pop(_L, 1); // Pop error
			}
			lua_pop(_L, 1); // Pop instance
		}
	}

	void LuaLanguageModule::OnPluginEnd(const Extension& plugin) {
		const auto& [instance, update, start, end] = *plugin.GetUserData().RCast<PluginData*>();
		if (end != LUA_NOREF) {
			lua_rawgeti(_L, LUA_REGISTRYINDEX, instance); // Stack: instance
			lua_rawgeti(_L, LUA_REGISTRYINDEX, end); // Stack: instance, plugin_end
			lua_pushvalue(_L, -2); // self
			if (lua_pcall(_L, 1, 0, 0) != LUA_OK) {
				LogError();
				_provider->Log(std::format(LOG_PREFIX "{}: call of 'plugin_end' failed", plugin.GetName()), Severity::Error);
				lua_pop(_L, 1); // Pop error
			}
			lua_pop(_L, 1); // Pop instance
		}
	}

	void LuaLanguageModule::OnMethodExport(const Extension& plugin) {
		TryCreateModule(plugin, true);
	}

	void LuaLanguageModule::TryCreateModule(const Extension& plugin, bool empty) {
		auto is_table_empty = [](lua_State *L, int index) {
			// Ensure the item at the given index is a table
			if (!lua_istable(L, index)) {
				luaL_error(L, "Expected a table");
				return 0; // Not a table
			}

			// Duplicate the table to avoid modifying the original
			lua_pushvalue(L, index);

			// Push nil as the initial key for lua_next
			lua_pushnil(L);

			// Try to get the first key-value pair
			if (lua_next(L, -2) == 0) {
				// No key-value pairs found, table is empty
				lua_pop(L, 1); // Pop the table copy
				return 1; // Empty
			}

			// A key-value pair was found, so the table is not empty
			lua_pop(L, 3); // Pop the key, value, and table copy
			return 0; // Not empty
		};

		const char* modname = plugin.GetName().data();

		lua_getglobal(_L, modname);
		if (!lua_isnil(_L, -1)) {
			if (!empty || !is_table_empty(_L, -1)) {
				lua_pop(_L, 1); // Pop the module table
				return; // Module already loaded or not empty
			}
		}
		lua_pop(_L, 1); // Clean up the stack

		// load
		luaL_requiref(_L, modname, &LoadEmpty, 0);

		LuaFunctionMap funcs = CreateFunctions(plugin);
		for (const auto& [name, func] : funcs) {
			lua_pushcfunction(_L, func);
			lua_setfield(_L, -2, name.data()); // module[func_name] = func
		}

		LuaEnumSet enums;
		for (const auto& method : plugin.GetMethods()) {
			CreateEnumObject(enums, method);
		}

		for (const auto& cls : plugin.GetClasses()) {
			CreateClassObject(funcs, cls);
		}

#if VERBOSE
		// stack top: module table
		lua_pushnil(_L); // first key
		while (lua_next(_L, -2) != 0) {  // -2: table, -1: value, -2: key
			const char* k = lua_tostring(_L, -2);
			int t = lua_type(_L, -1);

			_provider->Log(std::format(LOG_PREFIX "{}: {}", k, lua_typename(_L, t)), Severity::Debug);

			lua_pop(_L, 1); // pop value, keep key for next
		}
#endif

		lua_pop(_L, 1);
	}

	bool LuaLanguageModule::IsDebugBuild() {
		return LUALM_IS_DEBUG;
	}

	LuaLanguageModule g_lualm;
}

extern "C"
LUALM_EXPORT ILanguageModule* GetLanguageModule() {
	return &lualm::g_lualm;
}

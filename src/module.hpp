
#include <map>
#include <unordered_set>
#include <plugify/any.hpp>
#include <plugify/jit/call.hpp>
#include <plugify/jit/callback.hpp>
#include <plugify/language_module.hpp>
#include <plugify/method.hpp>
#include <plugify/module.hpp>
#include <plugify/plugin.hpp>

extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

namespace {
	template<typename T, typename... Rest>
	void hash_combine(std::size_t& seed, const T& v, const Rest&... rest) {
		seed ^= std::hash<T>{}(v) + 0x9e3779b9 + (seed << 6) + (seed >> 2);
		(hash_combine(seed, rest), ...);
	}
}

namespace lualm {
	template<typename T1, typename T2>
		struct pair_hash {
		size_t operator()(std::pair<T1, T2> const& p) const {
			size_t seed{};
			hash_combine(seed, p.first, p.second);
			return seed;
		}
	};

	// heterogeneous lookup
	struct string_hash {
		using is_transparent = void;
		[[nodiscard]] size_t operator()(const char* txt) const {
			return std::hash<std::string_view>{}(txt);
		}
		[[nodiscard]] size_t operator()(std::string_view txt) const {
			return std::hash<std::string_view>{}(txt);
		}
		[[nodiscard]] size_t operator()(const std::string& txt) const {
			return std::hash<std::string>{}(txt);
		}
	};

	enum class LuaAbstractType : size_t {
		Nil,
		Bool,
		LightUserData,
		Number,
		String,
		Table,
		Function,
		Userdata,
		Thread,

		/* custom types */
		Integer,
		Vector2,
		Vector3,
		Vector4,
		Matrix4x4,

		Max = Matrix4x4,

		Invalid = static_cast<size_t>(-1)
	};

	constexpr auto MaxLuaTypes = static_cast<size_t>(LuaAbstractType::Max);

	using LuaFunction = std::pair<int, int>;
	using LuaInternalMap = std::unordered_map<LuaFunction, void*, pair_hash<int, int>>;
	using LuaExternalMap = std::unordered_map<void*, LuaFunction>;
	using LuaEnumSet = std::unordered_set<std::string, string_hash, std::equal_to<>>;

	class LuaLanguageModule final : public plugify::ILanguageModule {
	public:
		LuaLanguageModule() = default;

		// ILanguageModule
		plugify::InitResult Initialize(std::weak_ptr<plugify::IPlugifyProvider> provider, plugify::ModuleHandle module) override;
		void Shutdown() override;
		void OnUpdate(plugify::DateTime dt) override;
		plugify::LoadResult OnPluginLoad(plugify::PluginHandle plugin) override;
		void OnPluginStart(plugify::PluginHandle plugin) override;
		void OnPluginUpdate(plugify::PluginHandle plugin, plugify::DateTime dt) override;
		void OnPluginEnd(plugify::PluginHandle plugin) override;
		void OnMethodExport(plugify::PluginHandle plugin) override;
		bool IsDebugBuild() override;

		const std::shared_ptr<plugify::IPlugifyProvider>& GetProvider() const { return _provider; }

	private:
		void AddToFunctionsMap(void* funcAddr, LuaFunction funcObj);
		LuaFunction FindExternal(void* funcAddr) const;
		void* FindInternal(LuaFunction funcObj) const;

		template<typename T>
		std::optional<T> ValueFromObject(int arg);
		template<class T, typename V> requires(std::is_signed_v<T> || std::is_unsigned_v<T>)
		std::optional<T> ValueFromIntegerObject(int arg);
		template<class T, typename V> requires(std::is_floating_point_v<T>)
		std::optional<T> ValueFromNumberObject(int arg);
		template<typename T>
		std::optional<plg::vector<T>> ArrayFromObject(int arg);
		template<typename T>
		bool PushLuaObject(const T& value);
		template<typename T>
		bool PushLuaObjectList(const plg::vector<T>& arrayArg);
		std::optional<void*> GetOrCreateFunctionValue(plugify::MethodHandle method, int arg);
		bool PushOrCreateFunctionObject(plugify::MethodHandle method, void* funcAddr);
		template<typename T>
		std::optional<T> GetObjectAttrAsValue(int absIndex, const char* attrName);
		std::pair<LuaAbstractType, const char*> GetObjectType(int arg) const;

		template<typename T>
		void* CreateValue(int arg);
		template<typename T>
		void* CreateArray(int arg);

		void SetFallbackReturn(plugify::ValueType retType, const plugify::JitCallback::Return* ret);
		bool SetReturn(int arg, plugify::PropertyHandle retType, const plugify::JitCallback::Return* ret);
		bool SetRefParam(int arg, plugify::PropertyHandle paramType, const plugify::JitCallback::Parameters* params, size_t index);
		bool ParamToObject(plugify::PropertyHandle paramType, const plugify::JitCallback::Parameters* params, size_t index);
		bool ParamRefToObject(plugify::PropertyHandle paramType, const plugify::JitCallback::Parameters* params, size_t index);

		struct ArgsScope {
			plugify::JitCall::Parameters params;
			std::vector<std::pair<void*, plugify::ValueType>> storage; // used to store array temp memory

			explicit ArgsScope(size_t size);
			~ArgsScope();
		};

		void BeginExternalCall(plugify::ValueType retType, ArgsScope& a) const;
		bool MakeExternalCallWithObject(plugify::PropertyHandle retType, plugify::JitCall::CallingFunc func, const ArgsScope& a, plugify::JitCall::Return& ret);
		bool PushObjectAsParam(plugify::PropertyHandle paramType, int arg, ArgsScope& a);
		bool PushObjectAsRefParam(plugify::PropertyHandle paramType, int arg, ArgsScope& a);
		bool StorageValueToObject(plugify::PropertyHandle paramType, const ArgsScope& a, size_t index);

	public:
		void GenerateEnum(LuaEnumSet& enumSet, plugify::PropertyHandle paramType);
		void GenerateEnum(LuaEnumSet& enumSet, plugify::MethodHandle method);
		void TryCreateModule(plugify::PluginHandle plugin, bool empty);
		void ResolveRequiredModule(std::string_view moduleName);
		std::vector<luaL_Reg> CreateFunctions(plugify::PluginHandle plugin);
		lua_CFunction OpenModule(std::string filename);
		void LogError();

		void InternalCall(plugify::MethodHandle method, plugify::MemAddr data, const plugify::JitCallback::Parameters* params, size_t count, const plugify::JitCallback::Return* ret);
		void ExternalCall(plugify::MethodHandle method, plugify::MemAddr data, const plugify::JitCallback::Parameters* params, size_t count, const plugify::JitCallback::Return* ret);

	private:
		std::shared_ptr<plugify::IPlugifyProvider> _provider;
		std::shared_ptr<asmjit::JitRuntime> _jitRuntime;
		lua_State* _L{nullptr};
		int _vector2Ref{LUA_REFNIL};
		int _vector3Ref{LUA_REFNIL};
		int _vector4Ref{LUA_REFNIL};
		int _matrix4x4Ref{LUA_REFNIL};
		struct PluginData {
			int instance;
			int update;
			int start;
			int end;
		};
		std::map<plugify::UniqueId, PluginData> _pluginsMap;
		struct LuaMethodData {
			plugify::JitCallback jitCallback;
			std::unique_ptr<LuaFunction> luaFunction;
		};
		std::vector<LuaMethodData> _luaMethods;
		struct JitHolder {
			plugify::JitCallback jitCallback;
			plugify::JitCall jitCall;
		};
		std::vector<JitHolder> _moduleFunctions;
		struct LoadHolder {
			plugify::JitCallback jitCallback;
			std::string filename;
		};
		std::vector<LoadHolder> _loadFunctions;
		std::vector<std::vector<luaL_Reg>> _createFunctions;
		struct ExternalHolder {
			plugify::JitCallback jitCallback;
			plugify::JitCall jitCall;
			std::unique_ptr<LuaFunction> luaFunction;
		};
		std::vector<ExternalHolder> _externalFunctions;
		std::vector<LuaMethodData> _internalFunctions;
		LuaExternalMap _externalMap;
		LuaInternalMap _internalMap;

	public:
		int _originalRequireRef{LUA_REFNIL};
	};
}

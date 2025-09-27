#pragma once

#include <plugify/call.hpp>
#include <plugify/callback.hpp>
#include <plugify/language_module.hpp>
#include <plugify/method.hpp>
#include <plugify/extension.hpp>
#include <plugify/logger.hpp>
#include <plugify/provider.hpp>
#include <plugify/enum_object.hpp>
#include <plugify/enum_value.hpp>

#include <plg/any.hpp>
#include <plg/format.hpp>

extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

#include <map>
#include <unordered_set>
#include <exception>

using namespace plugify;

namespace lualm {
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
	using LuaInternalMap = std::unordered_map<LuaFunction, void*, plg::pair_hash<int, int>>;
	using LuaExternalMap = std::unordered_map<void*, LuaFunction>;
	using LuaEnumSet = std::unordered_set<std::string, plg::string_hash, std::equal_to<>>;

	struct LuaMethodData {
		JitCallback jitCallback;
		std::unique_ptr<LuaFunction> luaFunction;
	};

	class LuaLanguageModule final : public ILanguageModule {
	public:
		LuaLanguageModule() = default;

		// ILanguageModule
		Result<InitData> Initialize(const Provider& provider, const Extension& module) override;
		void Shutdown() override;
		void OnUpdate(std::chrono::milliseconds dt) override;

		bool GenerateMethodExport(int pluginRef, const Method &method);

		Result<LoadData> OnPluginLoad(const Extension& plugin) override;
		void OnPluginStart(const Extension& plugin) override;
		void OnPluginUpdate(const Extension& plugin, std::chrono::milliseconds dt) override;
		void OnPluginEnd(const Extension& plugin) override;
		void OnMethodExport(const Extension& plugin) override;
		bool IsDebugBuild() override;

		const std::unique_ptr<Provider>& GetProvider() const { return _provider; }

	private:
		Result<LuaMethodData> GenerateMethodExport(const Method& method, int pluginRef);
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
		std::optional<void*> GetOrCreateFunctionValue(const Method& method, int arg);
		bool PushOrCreateFunctionObject(const Method& method, void* funcAddr);
		template<typename T>
		std::optional<T> GetObjectAttrAsValue(int absIndex, const char* attrName);
		std::pair<LuaAbstractType, const char*> GetObjectType(int arg) const;

		template<typename T>
		void* CreateValue(int arg);
		template<typename T>
		void* CreateArray(int arg);

		void SetFallbackReturn(ValueType retType, ReturnSlot& ret);
		bool SetReturn(int arg, const Property& retType, ReturnSlot& ret);
		bool SetRefParam(int arg, const Property& paramType, ParametersSpan& params, size_t index);
		bool ParamToObject(const Property& paramType, ParametersSpan& params, size_t index);
		bool ParamRefToObject(const Property& paramType, ParametersSpan& params, size_t index);

		struct ArgsScope {
			Parameters params;
			std::inplace_vector<std::pair<void*, ValueType>, Signature::kMaxFuncArgs> storage; // used to store array temp memory

			explicit ArgsScope(size_t size);
			~ArgsScope();
		};

		void BeginExternalCall(ValueType retType, ArgsScope& a) const;
		bool MakeExternalCallWithObject(const Property& retType, JitCall::CallingFunc func, const ArgsScope& a, Return& ret);
		bool PushObjectAsParam(const Property& paramType, int arg, ArgsScope& a);
		bool PushObjectAsRefParam(const Property& paramType, int arg, ArgsScope& a);
		bool StorageValueToObject(const Property& paramType, const ArgsScope& a, size_t index);

	public:
		void GenerateEnum(LuaEnumSet& enumSet, const Property& paramType);
		void GenerateEnum(LuaEnumSet& enumSet, const Method& method);
		void TryCreateModule(const Extension& plugin, bool empty);
		void ResolveRequiredModule(std::string_view moduleName);
		std::vector<luaL_Reg> CreateFunctions(const Extension& plugin);
		lua_CFunction OpenModule(std::string filename);
		void LogError();

		void InternalCall(const Method& method, MemAddr data, uint64_t* params, size_t count, void* ret);
		void ExternalCall(const Method& method, MemAddr data, uint64_t* params, size_t count, void* ret);

	private:
		std::unique_ptr<Provider> _provider;
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
		std::map<UniqueId, PluginData> _pluginsMap;
		std::vector<LuaMethodData> _luaMethods;
		struct JitHolder {
			JitCallback jitCallback;
			JitCall jitCall;
		};
		std::vector<JitHolder> _moduleFunctions;
		struct LoadHolder {
			JitCallback jitCallback;
			std::string filename;
		};
		std::vector<LoadHolder> _loadFunctions;
		std::vector<std::vector<luaL_Reg>> _createFunctions;
		struct ExternalHolder {
			JitCallback jitCallback;
			JitCall jitCall;
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

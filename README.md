[![Русский](https://img.shields.io/badge/Русский-%F0%9F%87%B7%F0%9F%87%BA-green?style=for-the-badge)](README_ru.md)

# Lua Language Module for Plugify

The Plugify Lua Language Module is a powerful extension for the Plugify project, enabling developers to write plugins in Lua and seamlessly integrate them into the Plugify ecosystem. Whether you're a Lua enthusiast or wish to leverage the lightweight and fast scripting of Lua for your plugins, this module provides the flexibility and ease of use you need.

## Features

- **Lua-Powered Plugins**: Write your plugins entirely in Lua, taking advantage of Lua’s simplicity and speed.
- **Seamless Integration**: Integrate Lua plugins effortlessly into the Plugify system, making them compatible with plugins written in other languages.
- **Cross-Language Communication**: Communicate seamlessly between Lua plugins and plugins written in other languages supported by Plugify.
- **Easy Configuration**: Utilize simple configuration files to define Lua-specific settings for your plugins.

## Getting Started

### Prerequisites

- Lua `5.4.7` is recommended.
- Plugify Framework Installed

### Installation

#### Option 1: Install via Plugify Plugin Manager

You can install the Lua Language Module using the Mamba package manager by running the following command:

```bash
mamba install -n your_env_name -c https://untrustedmodders.github.io/plugify-module-lua/ plugify-module-lua
```

#### Option 2: Manual Installation

1. Install dependencies:  

   a. Windows
   > Setting up [CMake tools with Visual Studio Installer](https://learn.microsoft.com/en-us/cpp/build/cmake-projects-in-visual-studio#installation)

   b. Linux:
   ```sh
   sudo apt-get install -y build-essential cmake ninja-build
   ```
   
   c. Mac:
   ```sh
   brew install cmake ninja
   ```

2. Clone this repository:

    ```bash
    git clone https://github.com/untrustedmodders/plugify-module-lua.git --recursive
    ```

3. Build the Lua language module:

    ```bash
    mkdir build && cd build
    cmake ..
    cmake --build .
    ```

### Usage

1. **Integration with Plugify**

   Ensure that your Lua language module is available in the same directory as your Plugify setup.

2. **Write Lua Plugins**

   Develop your plugins in Lua using the Plugify Lua API. Refer to the [Plugify Lua Plugin Guide](https://untrustedmodders.github.io/languages/lua/first-plugin) for detailed instructions.

3. **Build and Install Plugins**

   Put your Lua scripts in a directory accessible to the Plugify core.

4. **Run Plugify**

   Start the Plugify framework, and it will dynamically load your Lua plugins.

## Example

```lua
local Plugin = require('plugify').Plugin

local ExamplePlugin = {}
ExamplePlugin.__index = ExamplePlugin
setmetatable(ExamplePlugin, {__index = Plugin})

function ExamplePlugin.new()
    local self = setmetatable({}, ExamplePlugin)
    return self
end

function ExamplePlugin:plugin_start()
    print("Lua: OnPluginStart")
end

function ExamplePlugin:plugin_update(dt)
    print("Lua: OnPluginUpdate - Delta time:", dt)
end

function ExamplePlugin:plugin_end()
    print("Lua: OnPluginEnd")
end

```

## Documentation

For comprehensive documentation on writing plugins in Python using the Plugify framework, refer to the [Plugify Documentation](https://untrustedmodders.github.io).

## Contributing

Feel free to contribute by opening issues or submitting pull requests. We welcome your feedback and ideas!

## License

This Python Language Module for Plugify is licensed under the [MIT License](LICENSE).

[![English](https://img.shields.io/badge/English-%F0%9F%87%AC%F0%9F%87%A7-blue?style=for-the-badge)](README.md)

# Модуль языка Lua для Plugify

Модуль языка Lua для Plugify — это мощное расширение проекта Plugify, позволяющее разработчикам писать плагины на Lua и без труда интегрировать их в экосистему Plugify. Если вы энтузиаст Lua или хотите воспользоваться лёгкостью и скоростью этого языка, модуль предоставит всю необходимую гибкость и удобство.

## Возможности

- **Плагины на Lua**: Пишите плагины полностью на Lua, используя его простоту и высокую производительность.
- **Простая интеграция**: Лёгкая интеграция Lua-плагинов в систему Plugify, с совместимостью с плагинами на других языках.
- **Кросс-языковое взаимодействие**: Связь между Lua-плагинами и плагинами на других языках, поддерживаемых Plugify.
- **Удобная конфигурация**: Простые конфигурационные файлы для настройки параметров Lua-плагинов.

## Начало работы

### Требования

- Lua версии `5.4.7` (рекомендуется)
- Установленный фреймворк Plugify

### Установка

#### Вариант 1: Установка через менеджер плагинов Plugify

Вы можете установить модуль языка Lua с помощью менеджера плагинов Plugify, выполнив команду:

```bash
plg install plugify-module-lua
```

#### Вариант 2: Ручная установка

1. Установите зависимости:

   a. Windows  
   > Настройка [CMake-инструментов через Visual Studio Installer](https://learn.microsoft.com/en-us/cpp/build/cmake-projects-in-visual-studio#installation)

   b. Linux:  
   ```sh
   sudo apt-get install -y build-essential cmake ninja-build
   ```

   c. Mac:  
   ```sh
   brew install cmake ninja
   ```

2. Клонируйте репозиторий:

   ```bash
   git clone https://github.com/untrustedmodders/plugify-module-lua.git --recursive
   ```

3. Соберите модуль языка Lua:

   ```bash
   mkdir build && cd build
   cmake ..
   cmake --build .
   ```

### Использование

1. **Интеграция с Plugify**

   Убедитесь, что модуль языка Lua находится в той же директории, что и ваша установка Plugify.

2. **Создание плагинов на Lua**

   Разрабатывайте плагины на Lua, используя API Plugify для Lua. Подробности смотрите в [руководстве по Lua-плагинам](https://untrustedmodders.github.io/languages/lua/first-plugin).

3. **Сборка и установка плагинов**

   Поместите ваши Lua-скрипты в директорию, доступную для ядра Plugify.

4. **Запуск Plugify**

   Запустите фреймворк Plugify — он автоматически загрузит ваши Lua-плагины.

## Пример

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

## Документация

Полную документацию по созданию Lua-плагинов для Plugify вы найдёте в [официальной документации Plugify](https://untrustedmodders.github.io).

## Участие

Вы можете внести вклад, открыв issue или отправив pull request. Мы будем рады вашим идеям и отзывам!

## Лицензия

Этот модуль языка Lua для Plugify распространяется по лицензии [MIT](LICENSE).

#!/bin/bash
# build.sh - For Linux builds

set -ex

# Create the target directories
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
mkdir -p $PREFIX

# Copy the shared library and module file
cp bin/libplugify-module-lua.so $PREFIX/bin/
cp -r lib/* $PREFIX/lib/
cp plugify-module-lua.pmodule $PREFIX/

# Set proper permissions
chmod 755 $PREFIX/bin/libplugify-module-lua.so
chmod -R 755 $PREFIX/lib
chmod 644 $PREFIX/plugify-module-lua.pmodule

# Create activation scripts for proper library path
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

cat > $PREFIX/etc/conda/activate.d/plugify-module-lua.sh << EOF
#!/bin/bash
export PLUGIFY_LUA_MODULE_PATH="\${CONDA_PREFIX}:\${PLUGIFY_LUA_MODULE_PATH}"
EOF

cat > $PREFIX/etc/conda/deactivate.d/plugify-module-lua.sh << EOF
#!/bin/bash
export PLUGIFY_LUA_MODULE_PATH="\${PLUGIFY_LUA_MODULE_PATH//\${CONDA_PREFIX}:/}"
EOF

chmod +x $PREFIX/etc/conda/activate.d/plugify-module-lua.sh
chmod +x $PREFIX/etc/conda/deactivate.d/plugify-module-lua.sh
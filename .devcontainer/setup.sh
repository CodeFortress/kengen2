#!/bin/bash
set -e

# Install Lua
sudo apt-get update
sudo apt-get install -y lua5.4 luarocks

# Install LuaFileSystem via LuaRocks
sudo luarocks install luafilesystem
sudo luarocks install luaunit

# Verify installation
lua -e "require('lfs'); print('LFS installed successfully')"
lua -e "require('luaunit'); print('luaunit installed successfully')"

echo "Environment setup complete!"


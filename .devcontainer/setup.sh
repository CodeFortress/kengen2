#!/bin/bash
set -e

# Install Lua 5.4 and development packages
sudo apt-get update
sudo apt-get install -y lua5.4 lua5.4-dev luarocks

# Create symlink so 'lua' command works
sudo ln -sf /usr/bin/lua5.4 /usr/local/bin/lua

# Configure luarocks for lua5.4
sudo luarocks config lua_version 5.4
sudo luarocks config variables.LUA_INCDIR /usr/include/lua5.4
sudo luarocks config variables.LUA_LIBDIR /usr/lib/x86_64-linux-gnu

# Install packages
sudo luarocks install luafilesystem
sudo luarocks install luaunit

# Verify
lua -e "require('lfs'); require('luaunit'); print('All working!')"

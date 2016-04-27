#!/usr/bin/env node
process.env.NODE_ENV = 'bin';
process.chdir(__dirname);
process.chdir('../../');
require('coffee-script/register');
require('./run');

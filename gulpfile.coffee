gulp = require 'gulp'
supervisor = require 'gulp-supervisor'

gulp.task 'default', ->
    supervisor 'src/bin/www',
        args: []
        watch: ['.', 'src']
        pollInterval: 500
        extensions: ['coffee']
        exec: 'node'
        debug: true
        debugBrk: false
        harmony: false
        noRestartOn: false
        forceWatch: false
        quiet: false

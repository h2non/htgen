'use strict'

module.exports = (grunt) ->

  # load all grunt tasks
  (require 'matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    clean: ['htgen.js', 'lib', 'test/*.js', 'test/fixtures/.tmp/**']

    livescript:
      options:
        bare: true
        prelude: true
      src:
        expand: true
        cwd: 'src'
        src: ['*.ls']
        dest: 'lib'
        ext: '.js'

    mochacli:
      options:
        require: ['chai']
        compilers: ['ls:LiveScript']
        timeout: 5000
        ignoreLeaks: false
        ui: 'bdd'
        reporter: 'spec'
      all:
        src: [ 'test/*.ls' ]

    browserify:
      debug:
        options:
          standalone: 'htgen'
        files:
          'htgen.js': 'lib/htgen.js'

    uglify:
      options:
        beautify:
          beautify: yes
          indent_level: 2
        mangle: no
        compress: no
        report: 'min'
        banner: '/*! htgen.js - v<%= pkg.version %> - MIT License - https://github.com/h2non/htgen ' +
          '| Generated <%= grunt.template.today("yyyy-mm-dd hh:MM") %> */\n'
      debug:
        files:
          'htgen.js': ['htgen.js']
      min:
        options:
          beautify: no
          mangle: yes
          compress: yes
          report: 'min'
        files:
          'htgen.min.js': ['htgen.js']

    watch:
      options:
        spawn: false
      src:
        files: ['src/**/*.ls']
        tasks: ['test']
      test:
        files: ['test/**/*.ls']
        tasks: ['test']


  grunt.registerTask 'compile', [
    'clean'
    'livescript'
  ]

  grunt.registerTask 'test', [
    'compile',
    'mochacli'
  ]

  grunt.registerTask 'build', [
    'test'
    'browserify'
    'uglify'
  ]

  grunt.registerTask 'zen', [
    'test'
    'watch'
  ]

  grunt.registerTask 'publish', [
    'test'
    'build'
    'release'
  ]

  grunt.registerTask 'default', [
    'compile'
    'test'
  ]

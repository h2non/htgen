'use strict'

module.exports = (grunt) ->

  # load all grunt tasks
  (require 'matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    clean: ['htgen.js', 'test/*.js', 'test/fixtures/.tmp/**']

    livescript:
      options:
        bare: true
        prelude: true
      src:
        files:
          'htgen.js': ['src/htgen.ls']

      test:
        expand: true
        cwd: 'test/lib'
        src: ['**/*.ls']
        dest: 'test/lib'
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
      oli:
        options:
          standalone: 'htgen'
        files:
          'htgen.js': './htgen.js'

    uglify:
      options:
        beautify: true
        mangle: false
        compression: true
        report: 'min'
        banner: '/*! htgen - v<%= pkg.version %> - MIT License - https://github.com/h2non/htgen ' +
          '| Generated <%= grunt.template.today("yyyy-mm-dd hh:MM") %> */\n'
      min:
        files:
          'htgen.js': ['htgen.js']

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
    #'uglify'
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

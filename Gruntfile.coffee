'use strict'

module.exports = (grunt) ->
  # project configuration
  grunt.initConfig
    # load package information
    pkg: grunt.file.readJSON 'package.json'

    meta:
      banner: '/* ===========================================================\n' +
        '# <%= pkg.title || pkg.name %> - v<%= pkg.version %>\n' +
        '# ==============================================================\n' +
        '# Copyright (c) <%= grunt.template.today(\"yyyy\") %> SPHERE.IO\u2122\n' +
        '# Licensed <%= _.map(pkg.licenses, \"type\").join(\", \") %>.\n' +
        '#\n' +
        '#    <%= _.map(pkg.licenses, \"url\").join(\"\\n\") %>\n' +
        '*/\n'

    coffeelint:
      options: grunt.file.readJSON('node_modules/sphere-coffeelint/coffeelint.json')
      default: ['Gruntfile.coffee', 'src/**/*.coffee']

    clean:
      default: 'lib'
      test: 'test'

    coffee:
      options:
        bare: true
      default:
        files: grunt.file.expandMapping(['**/*.coffee'], 'lib/',
          flatten: false
          cwd: 'src/coffee'
          ext: '.js'
          rename: (dest, matchedSrcPath) ->
            dest + matchedSrcPath
          )
      test:
        files: grunt.file.expandMapping(['**/*.spec.coffee'], 'test/',
          flatten: false
          cwd: 'src/spec'
          ext: '.spec.js'
          rename: (dest, matchedSrcPath) ->
            dest + matchedSrcPath
          )

    concat:
      options:
        banner: '<%= meta.banner %>'
        stripBanners: true
      default:
        expand: true
        flatten: true
        cwd: 'lib'
        src: ['*.js']
        dest: 'lib'
        ext: '.js'

    # watching for changes
    watch:
      options:
        spawn: false
      default:
        files: ['src/coffee/*.coffee']
        tasks: ['build']
      test:
        files: ['src/**/*.coffee']
        tasks: ['test']
      doc:
        files: ['src/**/*.coffee']
        tasks: ['shell:doc', 'express:doc']

    express:
      doc:
        options:
          node_env: 'development'
          script: './scripts/server-doc.js'

    shell:
      options:
        stdout: true
        stderr: true
        failOnError: true
      coverage:
        command: '$(npm bin)/istanbul cover $(npm bin)/jasmine-node --captureExceptions test && cat ./coverage/lcov.info | ./node_modules/coveralls/bin/coveralls.js && rm -rf ./coverage'
      jasmine:
        command: 'jasmine-node --captureExceptions test'
      'jasmine-client':
        command: 'jasmine-node --captureExceptions test/client'
      'jasmine-connect':
        command: 'jasmine-node --captureExceptions test/connect'
      'jasmine-sync':
        command: 'jasmine-node --captureExceptions test/sync'
      'jasmine-integration':
        command: 'jasmine-node --captureExceptions test/integration'
      publish:
        command: 'npm publish'
      doc:
        command: './node_modules/.bin/biscotto'
      doc_publish:
        command: './scripts/publish-doc'

    bump:
      options:
        files: ['package.json']
        updateConfigs: ['pkg']
        commit: true
        commitMessage: 'chore(release): v%VERSION%'
        commitFiles: ['-a']
        createTag: true
        tagName: 'v%VERSION%'
        tagMessage: 'Version %VERSION%'
        push: true
        pushTo: 'origin'
        gitDescribeOptions: '--tags --always --abbrev=1 --dirty=-d'

  # load plugins that provide the tasks defined in the config
  grunt.loadNpmTasks 'grunt-bump'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-express-server'
  grunt.loadNpmTasks 'grunt-shell'

  # register tasks
  grunt.registerTask 'default', ['build']
  grunt.registerTask 'doc', ['shell:doc']
  grunt.registerTask 'doc:publish', ['build', 'shell:doc', 'shell:doc_publish']
  grunt.registerTask 'build', ['clean', 'coffeelint', 'coffee', 'concat']
  grunt.registerTask 'lint', ['coffeelint']
  grunt.registerTask 'test', 'Run test with optional target', (target) ->
    suffix = if target then "-#{target}" else ''
    grunt.task.run 'build', "shell:jasmine#{suffix}"
  grunt.registerTask 'coverage', ['build', 'shell:coverage']
  grunt.registerTask 'release', 'Release a new version, push it and publish it', (target) ->
    target = 'patch' unless target
    grunt.task.run "bump-only:#{target}", 'test', 'bump-commit', 'shell:publish'

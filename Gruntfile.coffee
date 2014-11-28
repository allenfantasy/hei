module.exports = (grunt) ->
  grunt.loadNpmTasks "grunt-browserify"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-cssmin"
  grunt.loadNpmTasks "grunt-contrib-less"
  grunt.loadNpmTasks "grunt-contrib-clean"
  #grunt.loadNpmTasks "grunt-exec"

  grunt.initConfig
    clean: ['www/index.js', 'www/index.min.js', 'www/index.css']

    connect:
      options:
        port: 1337
        livereload: 35729
        hostname: 'localhost'
      livereload:
        options:
          open: true
          base: ['www']

    less:
      default:
        files:
          "www/index.css": ["src/less/index.less"]

    browserify:
      default:
        files:
          "www/index.js": ["src/coffee/index.coffee"]
        options:
          transform: ['browserify-file', 'coffeeify', 'famousify', 'cssify', 'brfs', 'deamdify']
          ext: ".js"

    uglify:
      default:
        files:
          'www/index.min.js': ['www/index.js']

    watch:
      options:
        livereload: true
      gruntfile:
        files: ["Gruntfile.coffee"]
        options:
          reload: true
      js:
        files: ["src/coffee/*.coffee", "src/coffee/**/*.coffee"]
        tasks: ["browserify"]
        options:
          livereload: true
      css:
        files: "src/less/*.less"
        tasks: ["less"]
        options:
          livereload: true
      html:
        files: ["www/index.html", "src/**/*.html"]
        options:
          livereload: true

  grunt.registerTask "compile", "Compile assets", ->
    grunt.task.run [
      "browserify",
      "uglify",
      "less"
    ]

  grunt.registerTask "serve", "Start web server and watch", ->
    grunt.task.run [
      "clean"
      "compile"
      "connect:livereload"
      "watch"
    ]

  grunt.registerTask "build", "Build apps", ->
    grunt.task.run [
      "clean",
      "compile",
      "exec:cordova_build"
    ]

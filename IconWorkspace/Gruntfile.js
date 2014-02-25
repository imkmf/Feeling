module.exports = function(grunt) {
  grunt.initConfig({
    favicons: {
      options: {
        windowsTile: false,
        appleTouchBackgroundColor: 'none',
        appleTouchPadding: '0'
      },
      icons: {
        src: 'BaseIcon.png',
        dest: 'output/'
      }
    },
  })

  grunt.loadNpmTasks('grunt-favicons');
  grunt.registerTask('default', ['favicons'])
}

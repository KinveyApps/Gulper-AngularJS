module.exports = function(grunt) {

    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-sass');
    grunt.loadNpmTasks('grunt-contrib-jade');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-jasmine');

    grunt.loadNpmTasks('grunt-coffeelint');

//    grunt.loadNpmTasks('grunt-bower-task');
    grunt.loadNpmTasks('grunt-text-replace');
    grunt.loadNpmTasks('grunt-html2js');
    grunt.loadNpmTasks('grunt-script-link-tags');
    grunt.loadNpmTasks('grunt-useref');

    grunt.initConfig({

        pkg: grunt.file.readJSON('package.json'),
        bwr: grunt.file.readJSON('bower.json'),

        matchers: {
            sass: '**/*.scss',
            jade: '**/*.jade',
            coffee: '**/*.coffee',
            js: '**/*.js',
            jsModules: '**/module.js',
            css: '**/*.css',
            html: '**/*.html',
            all: '**/*'
        },

        paths: {

            lib: {
                base: 'lib'
            },

            src: {
                base: 'src',
                sass: 'sass',
                jade: 'jade',
                coffee: 'coffee',
                index: 'index.jade'
            },

            build: {
                base: 'build',
                js: 'js',
                css: 'css',
                html: 'html'
            },

            min: {
                base: 'min'
            },

            test: {
                base: 'test'
            }
        },

        clean: {
//            bower: ['<%= paths.lib.base %>'],
            build: ['<%= paths.build.base %>'],
            min: ['<%= paths.min.base %>'],
            tempmin: ['<%= paths.min.base %>/<%= paths.build.html %>', '<%= paths.min.base %>/<%= paths.build.css %>', '<%= paths.min.base %>/<%= paths.build.js %>', '<%= paths.min.base %>/<%= paths.lib.base %>'],
            test: ['<%= paths.build.base %>/<%= paths.test.base %>'],
            temp: ['.sass-cache']
        },

        copy: {
            build: {
                expand: true,
                cwd: '<%= paths.lib.base %>/',
                src: '**/*',
                dest: '<%= paths.build.base %>/<%= paths.lib.base %>/'
            },
            min: {
                expand: true,
                cwd: '<%= paths.build.base %>/',
                src: ['<%= matchers.all %>', '!<%= paths.lib.base %>/angular-mocks/<%= matchers.all %>'],
                dest: '<%= paths.min.base %>/'
            }
        },

//        bower: {
//            install: {
//                options: {
//                    targetDir: '<%= paths.lib.base %>/',
//                    cleanup: true
//                }
//            }
//        },

        coffeelint: {
            app: ['<%= paths.src.base %>/<%= paths.src.coffee %>/<%= matchers.coffee %>']
        },

        coffee: {
            app: {
                expand: true,
                flatten: false,
                options: {
                    bare: true
                },
                cwd: '<%= paths.src.base %>/<%= paths.src.coffee %>/',
                src: ['<%= matchers.coffee %>'],
                dest: '<%= paths.build.base %>/<%= paths.build.js %>/',
                ext: '.js'
            },
            test: {
                expand: true,
                flatten: false,
                options: {
                    bare: true
                },
                cwd: '<%= paths.src.base %>/<%= paths.test.base %>',
                src: ['<%= matchers.coffee %>'],
                dest: '<%= paths.build.base %>/<%= paths.test.base %>',
                ext: '.js'
            }
        },

        jade: {
            app: {
                expand: true,
                flatten: false,
                cwd: '<%= paths.src.base %>/<%= paths.src.jade %>/',
                src: ['<%= matchers.jade %>'],
                dest: '<%= paths.build.base %>/<%= paths.build.html %>/',
                ext: '.html',
                options: {
                    client: false,
                    pretty: true
                }
            },
            index: {
                expand: true,
                flatten: false,
                cwd: '<%= paths.src.base %>/',
                src: ['index.jade'],
                dest: '<%= paths.build.base %>/',
                ext: '.html',
                options: {
                    client: false,
                    pretty: true
                }
            }
        },

        sass: {
            app: {
                expand: true,
                flatten: false,
                cwd: '<%= paths.src.base %>/<%= paths.src.sass %>/',
                src: ['<%= matchers.sass %>'],
                dest: '<%= paths.build.base %>/<%= paths.build.css %>/',
                ext: '.css'
            }
        },

        tags: {
//            libjs: {
//                options: {
//                    scriptTemplate: '<script type="text/javascript" src="{{path}}"></script>',
//                    openTag: '<!--libjs start-->',
//                    closeTag: '<!--libjs end-->'
//                },
//                src: [
//                    '<%= paths.build.base %>/<%= paths.lib.base %>/angular/angular.js',
//                    '<%= paths.build.base %>/<%= paths.lib.base %>/<%= matchers.js %>',
//                    '!<%= paths.build.base %>/<%= paths.lib.base %>/angular-mocks/angular-mocks.js'
//                ],
//                dest: '<%= paths.build.base %>/index.html'
//            },
            libcss: {
                options: {
                    linkTemplate: '<link rel="stylesheet" type="text/css" href="{{path}}"/>',
                    openTag: '<!--libcss start-->',
                    closeTag: '<!--libcss end-->'
                },
                src: [
                    '<%= paths.build.base %>/<%= paths.lib.base %>/<%= matchers.css %>'
                ],
                dest: '<%= paths.build.base %>/index.html'
            },
            appjs: {
                options: {
                    scriptTemplate: '<script type="text/javascript" src="{{path}}"></script>',
                    openTag: '<!--appjs start-->',
                    closeTag: '<!--appjs end-->'
                },
                src: [
                    '<%= paths.build.base %>/<%= paths.build.js %>/app.js',
                    '<%= paths.build.base %>/<%= paths.build.js %>/<%= matchers.jsModules %>',
                    '<%= paths.build.base %>/<%= paths.build.js %>/<%= matchers.js %>'
                ],
                dest: '<%= paths.build.base %>/index.html'
            },
            appcss: {
                options: {
                    linkTemplate: '<link rel="stylesheet" type="text/css" href="{{path}}"/>',
                    openTag: '<!--appcss start-->',
                    closeTag: '<!--appcss end-->'
                },
                src: [
                    '<%= paths.build.base %>/<%= paths.build.css %>/<%= matchers.css %>'
                ],
                dest: '<%= paths.build.base %>/index.html'
            }
        },

        html2js: {
            options: {
                base: '<%= paths.min.base %>',
                module: 'app.templates'
            },
            app: {
                src: ['<%= paths.min.base %>/<%= paths.build.html %>/<%= matchers.html %>'],
                dest: '<%= paths.min.base %>/<%= paths.build.js %>/templates.js'
            }
        },

        replace: {
            min: {
                src: ['<%= paths.min.base %>/index.html'],
                overwrite: true,
                replacements: [{
                    from: 'APPVERSION',
                    to: '<%= bwr.name %>-<%= bwr.version %>'
                },{
                    from: 'LIBVERSION',
                    to: '<%= bwr.name %>-<%= bwr.version %>.lib'
                }]
            }
        },

        useref: {
            html: '<%= paths.min.base %>/index.html',
            temp: '<%= paths.min.base %>'
        },

        jasmine: {
            app: {
                src: [
                    '<%= paths.build.base %>/<%= paths.build.js %>/<%= matchers.jsModules %>',
                    '<%= paths.build.base %>/<%= paths.build.js %>/<%= matchers.js %>'
                ],
                options: {
                    specs: '<%= paths.build.base %>/<%= paths.test.base %>/<%= matchers.js %>',
                    vendor: [
                        '<%= paths.lib.base %>/angular/angular.js',
                        '<%= paths.lib.base %>/<%= matchers.js %>'
                    ],
                    summary: true
                }
            }
        },

        watch: {
            app: {
                files: [
                    '<%= paths.src.base %>/<%= paths.src.coffee %>/<%= matchers.coffee %>',
                    '<%= paths.src.base %>/<%= paths.src.sass %><%= matchers.sass %>',
                    '<%= paths.src.base %>/<%= paths.src.jade %>/<%= matchers.jade %>',
                    '<%= paths.src.base %>/<%= paths.test.base %>/<%= matchers.coffee %>'
                ],
                tasks: ['build'],
                options: {
                    interrupt: true
                }
            }
        }

    });

//    grunt.registerTask('install', ['clean:bower', 'bower:install']);
//    grunt.registerTask('lint', ['coffeelint:app']);
    grunt.registerTask('build', ['clean:build', 'copy:build', 'coffee:app', 'jade:app', 'jade:index', 'sass:app', 'clean:temp', 'tags:appjs', 'tags:libcss', 'tags:appcss']);
    grunt.registerTask('test', ['clean:test', 'coffee:test', 'jasmine:app']);
    grunt.registerTask('min', ['clean:min', 'copy:min', 'html2js:app', 'replace:min', 'useref', 'concat', 'uglify', 'cssmin', 'clean:tempmin']);

};
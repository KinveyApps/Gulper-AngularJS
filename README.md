# angular-grunt-seed

An opinionated [AngularJS](http://angularjs.org/) boilerplate project with [Grunt](http://gruntjs.com/) for tooling

[![Build Status](https://travis-ci.org/ninjatronic/angular-grunt-seed.png)](https://travis-ci.org/ninjatronic/angular-grunt-seed)

## Philosophy

This project aims to provide a scalable boilerplate using the latest tools for professional AngularJS application development. If you are an AngularJS beginner then this boilerplate is probably not for you.

### Technologies

Although Javascript, HTML and CSS are widely used they can be difficult to read and maintain. This boilerplate engages compile-to-web technologies to reduce the amount of code you have to write and improve readability and maintainability. Herein, scripts are written in [Coffeescript](http://coffeescript.org/), stylesheets in [SASS](http://sass-lang.com/) and templates in [Jade](http://jade-lang.com/).

The tooling is written with Grunt and watches the filesystem to any changes to your source and automatically compiles your source files down to HTML/JS/CSS files to view in the browser.

### Structure

Source files are kept in `src/coffee`, `src/jade` and `src/sass` and compile to `build/js`, `build/html` and `build/css`. Hopefully these naming conventions are sufficiently self explanatory. Once they have been compiled the manifest is automatically populated in `build/index.html`, which is compiled from `src/index.jade`.

Test files are written in Coffeescript against [Jasmine](http://jasmine.github.io/2.0/introduction.html), kept in `src/test` and compile to `build/test`. There is no `jasmine.conf.js` file as the configuration is specified in `Gruntfile.js`.

Within these directories you can organise your code as you wish (provided you keep SASS files in the `sass` directory etc). Apart from these named directories there are three special files that the build script relies upon:

* `src/index.jade` This file acts as the application manifest. Apart from metadata about the project, which you can edit at will, there are sets of comments which denote where the buildscript will generate the `script` and `link` tags.
* `src/coffee/app.coffee` This is the top-level module definition for the AngularJS application.
* `src/coffee/templates.coffee` This is a placeholder module definition which is used by the build script to inject templates into the browser cache at config-time

The final, minified product is generated into the `min/` directory. There are two javascript files, two css files and one html file.

## Usage

### Prerequisites

This document assumes you have the following installed:

* [NodeJS](http://nodejs.org/)
* [Grunt](http://gruntjs.com/)
* [Bower](http://bower.io/)
* [Ruby](https://www.ruby-lang.org/)
* [SASS](http://sass-lang.com/)
* [SCSS Lint](https://github.com/causes/scss-lint)

### Getting Started

Fork the repo or download the zipped code. Then, after installing the above prerequisites, you can install the bower dependencies using `grunt install`.

You can start the file-system watcher using `grunt watch`. This watcher will watch your code and keep your compiled files up to date with any changes as well as linting and testing your code.

To produce the minified build you can run `grunt min`.
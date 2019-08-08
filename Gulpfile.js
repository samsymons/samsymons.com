const gulp = require("gulp");
const postcss = require('gulp-postcss');
const autoprefixer = require('autoprefixer');
const sass = require("gulp-sass");
const hash = require("gulp-hash");
const del = require("del");

function clean() {
  return del(["static/css/**/*", "static/js/**/*", "static/images/**/*"])
}

function css() {
  return gulp.src("assets/scss/**/*.scss")
    .pipe(sass({
      outputStyle: "compressed"
    }))
    .pipe(postcss([autoprefixer()]))
    .pipe(hash())
    .pipe(gulp.dest("static/css"))
    .pipe(hash.manifest("hash.json"))
    .pipe(gulp.dest("data/css"))
}

function images() {
    return gulp.src("assets/images/**/*")
      .pipe(gulp.dest("static/images"))
}

// Process JavaScript

function js() {
  return gulp.src("assets/js/**/*")
    .pipe(hash())
    .pipe(gulp.dest("static/js"))
    .pipe(hash.manifest("hash.json"))
    .pipe(gulp.dest("data/js"))
}

const build = gulp.series(clean, gulp.parallel(css, images, js));
exports.build = build;

exports.default = function () {
  gulp.watch('assets/**/*', {
    ignoreInitial: false
  }, function (cb) {
    build();
    cb();
  });
};
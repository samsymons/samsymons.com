var gulp         = require("gulp"),
    sass         = require("gulp-sass"),
    autoprefixer = require("gulp-autoprefixer")
    hash         = require("gulp-hash"),
    del          = require("del")

// Process SCSS

gulp.task("scss", function() {
  del(["static/css/**/*"])

  gulp.src("assets/scss/**/*.scss")
      .pipe(sass({outputStyle: "compressed"}))
      .pipe(autoprefixer({browsers: ["last 20 versions"]}))
      .pipe(hash())
      .pipe(gulp.dest("static/css"))
      .pipe(hash.manifest("hash.json"))
      .pipe(gulp.dest("data/css"))
})

// Process Images

gulp.task("images", function () {
  del(["static/images/**/*"])

  gulp.src("assets/images/**/*")
      .pipe(gulp.dest("static/images"))
})

// Process JavaScript

gulp.task("js", function () {
  del(["static/js/**/*"])

  gulp.src("assets/js/**/*")
      .pipe(hash())
      .pipe(gulp.dest("static/js"))
      .pipe(hash.manifest("hash.json"))
      .pipe(gulp.dest("data/js"))
})

gulp.task("watch", ["scss", "images", "js"], function () {
  gulp.watch("assets/scss/**/*", ["scss"])
  gulp.watch("assets/images/**/*", ["images"])
  gulp.watch("assets/js/**/*", ["js"])
})

gulp.task("default", ["watch"])

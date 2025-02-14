base_pkg_ <- c(
  "base",
  "boot",
  "class",
  "cluster",
  "codetools",
  "compiler",
  "datasets",
  "foreign",
  "graphics",
  "grDevices",
  "grid",
  "KernSmooth",
  "lattice",
  "MASS",
  "Matrix",
  "methods",
  "mgcv",
  "nlme",
  "nnet",
  "parallel",
  "rpart",
  "spatial",
  "splines",
  "stats",
  "stats4",
  "survival",
  "tcltk",
  "tools",
  "utils"
)

descdir <- tempfile(pattern = "desc")
dir.create(descdir)
file.copy("DESCRIPTION", descdir)

usethis::with_project(descdir, {
  test_that("dock_from_desc works", {
    my_dock <- dock_from_desc(file.path(descdir, "DESCRIPTION"))

    expect_s3_class(my_dock, "R6")
    expect_s3_class(my_dock, "Dockerfile")

    tpf <- tempfile()

    my_dock$write(tpf)

    tpf <- paste(
      readLines(tpf),
      collapse = " "
    )

    expect_true(
      grepl(
        "rocker/r-ver",
        tpf
      )
    )
    expect_true(
      grepl(
        "apt-get update && apt-get install",
        tpf
      )
    )
    expect_true(
      grepl(
        "mkdir /build_zone",
        tpf
      )
    )
    expect_true(
      grepl(
        "rm -rf /build_zone",
        tpf
      )
    )

    x <- desc::desc_get_deps()
    x <- x[x$type == "Imports" & !(x$package %in% base_pkg_), ]
    if (length(x) > 0) {
      for (i in x$package) {
        cat(i)
        expect_true(
          grepl(
            i,
            tpf
          )
        )
      }
    }

    # Only if package I guess
    # expect_true(file.exists(file.path(descdir, ".Rbuildignore")))
    expect_true(file.exists(file.path(descdir, ".dockerignore")))
  })
})

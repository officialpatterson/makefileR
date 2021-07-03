isHelloWorld <- function(helloString) {
  stringi::stri_cmp("hello world", helloString)
}

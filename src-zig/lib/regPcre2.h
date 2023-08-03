#include <pcre2posix.h>
#include <stdbool.h>

bool isMatch(regex_t *re, char const *input) {
  regmatch_t pmatch[0];
  return pcre2_regexec(re, input, 0, pmatch, 0) == 0;
}
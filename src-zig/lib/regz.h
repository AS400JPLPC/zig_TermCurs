#include <regex.h>
#include <stdbool.h>

bool isMatch(regex_t *re, char const *input) {
  regmatch_t pmatch[0];
  return regexec(re, input, 0, pmatch, 0) == 0;
}
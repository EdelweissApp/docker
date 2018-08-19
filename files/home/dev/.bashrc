export PATH="$PATH:$HOME/.composer/vendor/bin"

if [ -f /.dockerenv ]; then
    PROMPT_HOST="docker"
else
    PROMPT_HOST="\h"
fi
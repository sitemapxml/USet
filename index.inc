path_functions='./includes/functions.inc'
path_input='./includes/input.inc'
path_install='./includes/install.inc'
path_lang_dir='./languages/'
path_lang_welcome='./languages/welcome/'

# Language setting
# Load definied language and if file does not exist revert to en.txt
if [ -f "${path_lang_dir}$conf_language.txt" ]; then
  source ${path_lang_dir}$conf_language.txt
else
  source ${path_lang_dir}en.txt
fi
if [ -f "${path_lang_welcome}$conf_language.txt" ]; then
  source ${path_lang_welcome}$conf_language.txt
else
  source ${path_lang_welcome}en.txt
fi

# Load functions
if [ -f "$path_functions" ]; then
  source $path_functions
else
  echo "Fatal error: functions.inc not found. Aborting..."
  sleep 1s
  exit 1
fi

# Load options
if [ -f "$path_input" ]; then
  source $path_input
else
  echo "Fatal error: input.inc not found. Aborting..."
  sleep 1s
  exit 1
fi

# Load main installation process
if [ -f "$path_install" ]; then
  source $path_install
else
  echo "Fatal error: install.inc not found. Aborting..."
  sleep 1s
  exit 1
fi

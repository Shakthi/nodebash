
set -x
. bashnode.bash
bashnode import -i tester  'teest.bash'
bashnode import -i tester  'test.bash'

bashnode import -i tester2  'test.bash'

bashnode import -i tester3  'test2.bash'
#bashnode import -i '-' 'test2.bash'
bashnode import  'test2.bash'


set

#!/bin/bash

quotesource='http://www.quotedb.com/quote/quote.php?action=random_quote&c[126]=126'

#curl -s -g "${quotesource}" |sed -e :a -e 's/<[^>]*>//g;/</N;//ba' | \

src=$(curl -s -g  "${quotesource}")
src2=$(echo "$src" |grep '^<span' | grep -v 'quotedb'| sed "s/.*write(\'\(.*\)\<b.*/\1/")
src3=$(echo "$src" |grep '^<span' | grep -v 'quotedb'| sed "s/.*i\>\(.*\)a\>.*/\1/")

echo $src2
echo "$src3" | sed 's/\(.*\">\).*\</\1/'
#echo "$src" |grep '^<span' | grep -v 'quotedb'

#	sed -e :hel -e 's/^var*//g;/</N;//bhel' | \
#	sed -e :hel2 -e 's/_gaq*//g;/</N;//bhel2' | \
#	sed -e :hel3 -e 's/{*//g;/</N;//bhel3' | \
#	sed -e :hel4 -e 's/.*if.*//g;/</N;//bhel4' | \
   # sed -e s/document.write\(\'//g | \
   # sed -e s/\'\)\;//g | \
   # sed 's/More quotes from /  -- /g'| \
   # sed '/text\\/javascript/{:yy;N;/<\/script>/!byy;s/.*})();\n\n<\/script>|.*} catch(err) {}<\/script>//}' | \
   # sed '$!N;s/\n/ /'
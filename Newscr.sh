#!/bin/bash

path=/opt/curbas/scripts/tools/MonitorScripts

df -PTh | \
sed '1d' | \
sort -n -k6 | \
awk '{
    printf "\n\t<tr>";
    for (n = 1; n < 7; ++n)
        printf("\n\t<td>%s</td>",$n);
        printf "\n\t<td>";
        for(;n <= NF; ++n)
            printf("%s ",$n);
            printf "</td>\n\t</tr>"
}' > Newscr2.html

free -m | grep -v "buffers/cache" | \
sed '1d' | \
sort -n -k6 | \
awk '{
    printf "\n\t<tr>";
    for (n = 1; n < 7; ++n)
        printf("\n\t<td>%s</td>",$n);
        printf "\n\t<td>";
        for(;n <= NF; ++n)
            printf("%s ",$n);
            printf "</td>\n\t</tr>"
}' > Newscr5.html


top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}' >> 4.html

ps -e -o pcpu -o pid -o user -o args | grep -v "%CPU" | sort -k1 -r | head -6 | awk '{
    printf "\n\t<tr>";
    for (n = 1; n < 4; ++n)
        printf("\n\t<td>%s</td>",$n);
        printf "\n\t<td>";
        for(;n <= NF; ++n)
            printf("%s ",$n);
            printf "</td>\n\t</tr>"
}' > Newscr6.html


ps -e -o pmem -o pid -o user -o args | grep -v "MEM" | sort -k1 -r | head -6 | awk '{
    printf "\n\t<tr>";
    for (n = 1; n < 4; ++n)
        printf("\n\t<td>%s</td>",$n);
        printf "\n\t<td>";
        for(;n <= NF; ++n)
            printf("%s ",$n);
            printf "</td>\n\t</tr>"
}' > Newscr7.html

cat $path/1.html > NEWSCRIPT.html
cat $path/Newscr2.html >> NEWSCRIPT.html
cat $path/3.html >> NEWSCRIPT.html
cat $path/2.html >> NEWSCRIPT.html
cat $path/Newscr5.html >> NEWSCRIPT.html
cat $path/3.html >> NEWSCRIPT.html
cat $path/4.html >> NEWSCRIPT.html
cat $path/5.html >> NEWSCRIPT.html
cat $path/6.html >> NEWSCRIPT.html
cat $path/Newscr6.html >> NEWSCRIPT.html
cat $path/3.html >> NEWSCRIPT.html
cat $path/8.html >> NEWSCRIPT.html
cat $path/Newscr7.html >> NEWSCRIPT.html
cat $path/3.html >> NEWSCRIPT.html
cat $path/7.html >> NEWSCRIPT.html


( echo To:DL-GR-PROVFIX@internal.vodafone.com
  echo From:noreply@vodafone.com
  echo "Content-Type: text/html;"
  echo Subject: Health Check up Report: `hostname`.
  cat $path/NEWSCRIPT.html
)| /usr/sbin/sendmail -t
   sed -i '$ d' $path/4.html

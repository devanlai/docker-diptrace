FROM tianon/wine:32

MAINTAINER Devan Lai <devan.lai@gmail.com>

RUN apt-get -y update && apt-get install -y xvfb

COPY bin/* /tmp/bin/

ENV WINEDLLOVERRIDES="mscoree,mshtml="
RUN if [ ! -d ${WINEPREFIX:-~/.wine/} ]; then \
xvfb-run -a wine winecfg /D && \
/tmp/bin/waitfor.sh wineserver; \
fi

RUN wine reg ADD "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion" \
/v "ProductName" /t REG_SZ /d "Microsoft Windows Vista";

COPY exe/*.exe /tmp/exe/


RUN xvfb-run -a wine \
/tmp/exe/dipfree_beta.exe /silent /hide; \
/tmp/bin/waitfor.sh wineserver; \
test -f "`winepath 'C:\\Program Files\\DipTrace Beta\\Schematic.exe'`" && \
test -f "`winepath 'C:\\Program Files\\DipTrace Beta\\Pcb.exe'`" && \
ln -s "`winepath 'C:\\Program Files\\DipTrace Beta'`" "`winepath 'C:\\Program Files\\DipTrace'`" && \
test -f "`winepath 'C:\\Program Files\\DipTrace\\Schematic.exe'`"

RUN rm -rf /tmp/exe/
RUN rm -rf /tmp/bin/
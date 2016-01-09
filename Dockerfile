FROM debian:jessie

MAINTAINER Devan Lai <devan.lai@gmail.com>

RUN dpkg --add-architecture i386
RUN apt-get -y update && apt-get install -y wine:i386 xvfb procps

COPY bin/* /tmp/bin/

# Do some minimal wine initialization
ENV WINEDLLOVERRIDES="mscoree,mshtml="
RUN if [ ! -d ${WINEPREFIX:-~/.wine/} ]; then \
xvfb-run -a wine winecfg /D && \
/tmp/bin/waitfor.sh wineserver; \
fi

# Configure as Vista to avoid OS-too-old warnings
RUN wine reg ADD "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion" \
/v "ProductName" /t REG_SZ /d "Microsoft Windows Vista";

COPY exe/*.exe /tmp/exe/

# Run the installer
RUN xvfb-run -a wine \
/tmp/exe/dipfree_en.exe /silent /hide; \
/tmp/bin/waitfor.sh wineserver;

# Verify it succeeded
RUN xvfb-run -a \
test -f "`winepath 'C:\\Program Files\\DipTrace\\Schematic.exe'`" && \
test -f "`winepath 'C:\\Program Files\\DipTrace\\Pcb.exe'`"; \
/tmp/bin/waitfor.sh wineserver;

# Cleanup temp files
RUN rm -rf /tmp/*

FROM alpine:latest

# MAINTAINER
MAINTAINER 852203465@qq.com

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' >/etc/timezone

# 创建工作目录
WORKDIR /usr/local/java

ADD jre-8u351-linux-x64.tar.gz /usr/local/java/
COPY glibc-2.33-r0.apk /usr/local/java/
COPY glibc-bin-2.33-r0.apk /usr/local/java/
COPY glibc-i18n-2.33-r0.apk /usr/local/java/
COPY locale.md /usr/local/java/
ADD Fonts.tar.gz /usr/share/fonts/

RUN set -eux  \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories  \
    &&apk update  \
    && apk upgrade  \
    && apk --no-cache add ca-certificates wget  \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && apk add glibc-bin-2.33-r0.apk glibc-i18n-2.33-r0.apk glibc-2.33-r0.apk  \
    && rm -rf *.apk  \
    && rm -rf /var/cache/apk/*

RUN cd /usr/local/java/jre1.8.0_351 \
    && rm -rf COPYRIGHT LICENSE README release THIRDPARTYLICENSEREADME-JAVAFX.txtTHIRDPARTYLICENSEREADME.txt Welcome.html \
        rm -rf lib/plugin.jar \
        lib/ext/jfxrt.jar \
        bin/javaws \
        lib/javaws.jar \
        lib/desktop \
        plugin \
        lib/deploy* \
        lib/*javafx* \
        lib/*jfx* \
        lib/amd64/libdecora_sse.so \
        lib/amd64/libprism_*.so \
        lib/amd64/libfxplugins.so \
        lib/amd64/libglass.so \
        lib/amd64/libgstreamer-lite.so \
        lib/amd64/libjavafx*.so \
        lib/amd64/libjfx*.so

# 设置JAVA变量环境
ENV JAVA_HOME=/usr/local/java/jre1.8.0_351
ENV CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/lib:$CLASSPATH
ENV PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/bin

RUN cat locale.md | xargs -i /usr/glibc-compat/bin/localedef -i {} -f UTF-8 {}.UTF-8  \
    && rm -rf locale.md

# 指定语言
ENV LANG=zh_CN.UTF-8 \
  LANGUAGE=zh_CN.UTF-8

#安装字体软件，完成字体配置
RUN apk add --update ttf-dejavu fontconfig \
    && chmod 777 /usr/share/fonts \
    && fc-cache -fv

# 检查环境
RUN java -version \
    && fc-list \
    && /usr/glibc-compat/bin/locale -a

WORKDIR /

CMD ["java","-version"]
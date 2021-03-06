FROM python:3.6.1-alpine

RUN	log () { echo -e "\033[01;95m$@\033[0m"; } && \
\
	apk add --no-cache --virtual .build-deps \
		gcc \
		linux-headers \
		make \
		musl-dev \
		pcre-dev && \
\
	apk add --no-cache --virtual .run-deps \
		pcre && \
\
	log "Temporarily link cc1 to gcc for uwsgi build" && \
	ln -s /usr/bin/gcc /usr/bin/cc1 && \
\
	BUILD_DIR="$(mktemp -d)" && \
	UWSGI_VERSION=2.0.15 && \
\
	log "Download and unpack uwsgi-$UWSGI_VERSION.tar.gz" && \
	wget -O "$BUILD_DIR/uwsgi.tar.gz" "http://projects.unbit.it/downloads/uwsgi-$UWSGI_VERSION.tar.gz" && \
	tar -xvzC $BUILD_DIR -f "$BUILD_DIR/uwsgi.tar.gz" && \
\
	log "Build and install uwsgi-$UWSGI_VERSION" && \
	cd $BUILD_DIR/uwsgi-$UWSGI_VERSION && \
	python uwsgiconfig.py --build default && \
	python setup.py install && \
\
	log "Make a default uwsgi configuration" && \
	mkdir -p /usr/src/app && \
	echo -e "[uwsgi]\nsocket = 127.0.0.1:9000" > /usr/src/app/uwsgi.ini && \
\
	log "Clean up" && \
	rm -r $BUILD_DIR && \
	rm /usr/bin/cc1 && \
	apk del .build-deps

WORKDIR /usr/src

EXPOSE 9000 9002

CMD ["uwsgi", "/usr/src/app/uwsgi.ini"]

LABEL maintainer="King Chung Huang <kchuang@ucalgary.ca>"

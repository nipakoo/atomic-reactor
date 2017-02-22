FROM fedora:latest

RUN dnf -y install git python-docker-py python-setuptools e2fsprogs koji python-backports-lzma osbs gssproxy && dnf clean all
ADD ./atomic-reactor.tar.gz /tmp/

# Workaround to list our koji host since --add-host is not supported for "docker build" yet
RUN cp /etc/hosts /tmp/hosts
RUN mkdir -p -- /lib-override && cp /usr/lib64/libnss_files.so.2 /lib-override
RUN sed -i 's:/etc/hosts:/tmp/hosts:g' /lib-override/libnss_files.so.2
ENV LD_LIBRARY_PATH /lib-override
RUN echo "<koji ip here> <koji url here> <koji name>" >> /tmp/hosts

COPY koji.conf /etc/
COPY client.crt /root/.koji/cert
COPY clientca.crt /root/.koji/ca
COPY serverca.crt /root/.koji/serverca

RUN cd /tmp/atomic-reactor/ && python setup.py install
CMD ["atomic-reactor", "--verbose", "inside-build"]

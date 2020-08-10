FROM centos:7.6.1810

# install some utilities
RUN yum -y install              \
        wget.x86_64             \
        unzip.x86_64            \
        zlib-devel.x86_64       \
        tree.x86_64             \
        libcurl-devel.x86_64

# install the software collection repository
RUN yum -y install centos-release-scl

# install the devtoolset-3 collection (with gcc 4.9.2)
# devtoolset-3 is EOF (02/20), so we need to use yum-utils to add an archive mirror
# and install from there
RUN yum install yum-utils -y
RUN yum-config-manager --add-repo="http://linuxsoft.cern.ch/centos-vault/centos/7.6.1810/sclo/x86_64/rh"
RUN yum -y install devtoolset-3

# install the devtoolset-6 collection (with gcc 6.3.1)
RUN yum -y install devtoolset-6

# install cmake 3.7.2
RUN mkdir /opt/cmake /tmp/cmake && cd /tmp/cmake && \
    wget https://cmake.org/files/v3.7/cmake-3.7.2-Linux-x86_64.sh && \
    chmod +x ./cmake-3.7.2-Linux-x86_64.sh && \
    ./cmake-3.7.2-Linux-x86_64.sh --skip-license --prefix=/opt/cmake

# install git 2.21.0
RUN scl enable devtoolset-3 /bin/bash && \
    mkdir /opt/git /tmp/git && cd /tmp/git && \
    wget https://github.com/git/git/archive/v2.21.0.zip && \
    unzip v2.21.0.zip && cd git-2.21.0 && \
    NO_GETTEXT=1 NO_TCLTK=1 NO_EXPAT=1 NO_OPENSSL=1 make prefix=/opt/git -j4 install

# create a new user
ARG USER_NAME
ARG USER_ID
ARG GROUP_ID
RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    groupadd -g ${GROUP_ID} ${USER_NAME} && \
    useradd -l -u ${USER_ID} -g ${USER_NAME} ${USER_NAME} && \
    install -d -m 0755 -o ${USER_NAME} -g ${USER_NAME} /home/${USER_NAME} \
    ;fi

# create mount points
VOLUME /datas/${USER_NAME} /s/apps/packages

# set environment variables
ENV TERM xterm-256color
ENV USER ${USER_NAME}
ENV PATH="/opt/cmake/bin:/opt/git/bin:${PATH}"

# end of build:base setup

# enable devtoolset-3 collection
RUN echo 'unset BASH_ENV PROMPT_COMMAND ENV' > /usr/bin/scl_enable
RUN echo 'source scl_source enable devtoolset-3' >> /usr/bin/scl_enable
ENV BASH_ENV="/usr/bin/scl_enable"
ENV ENV="/usr/bin/scl_enable"
ENV PROMPT_COMMAND=". /usr/bin/scl_enable"

# set environment variables
ENV CC="gcc"
ENV CXX="g++"

# set user
ARG USER_NAME
USER ${USER_NAME}

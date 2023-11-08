# Use Fedora 36 as the base image
FROM fedora:36

# Install build dependencies
RUN dnf update -y && dnf install -y \
    arm-none-eabi-gcc \
    arm-none-eabi-gcc-cs-c++ \
    arm-none-eabi-newlib \
    autoconf \
    clang \
    clang-devel \
    clang-tools-extra \
    cmake \
    diffutils \
    expat-devel \
    file \
    findutils \
    flex \
    gcc \
    gettext-devel \
    git \
    glibc-devel.i686 \
    gnulib-devel \
    libcgroup-tools \
    libcurl-devel \
    libtool \
    libzstd \
    llvm \
    llvm-devel \
    lzip \
    make \
    openssl-devel \
    pip \
    procps-ng \
    python \
    python3-devel \
    tcl \
    texinfo \
    unzip \
    vim \
    vim-common \
    wget \
    zlib-devel

# Install Bear
COPY bear-3.0.21-2.fc36.x86_64.rpm /bear/bear-3.0.21-2.fc36.x86_64.rpm
RUN cd bear/ && dnf install -y bear-3.0.21-2.fc36.x86_64.rpm

# Install Infer
RUN mkdir -p /infer
COPY infer/share /infer/share
COPY infer/lib /infer/lib
RUN gunzip -f /infer/lib/infer/facebook-clang-plugins/clang/install/bin/clang-13.gz
RUN gunzip -f /infer/lib/infer/infer/bin/infer.gz
COPY infer_symlink /opt/naivesystems/infer_symlink
RUN chmod +x /opt/naivesystems/infer_symlink && /opt/naivesystems/infer_symlink
RUN ln -s /infer/bin/infer /usr/local/bin/infer

# Install Cppcheck
COPY cppcheck /cppcheck
RUN alias cppcheck=cppcheck/cppcheck

# Install ProjectConverter
RUN pip install lxml==4.9.1
RUN pip install jinja2
COPY ProjectConverter /ProjectConverter

# Install Cpplint
RUN pip install -i https://mirrors.aliyun.com/pypi/simple/ flake8>=4.0.1
RUN pip install -i https://mirrors.aliyun.com/pypi/simple/ flake8-polyfill
RUN pip install -i https://mirrors.aliyun.com/pypi/simple/ pylint>=2.11.0
RUN pip install -i https://mirrors.aliyun.com/pypi/simple/ tox>=3.0.0
RUN pip install -i https://mirrors.aliyun.com/pypi/simple/ tox-pyenv
RUN pip install -i https://mirrors.aliyun.com/pypi/simple/ importlib-metadata>=0.12
COPY cpplint.py /opt/naivesystems/cpplint.py

COPY "clang.gz" "/opt/naivesystems/clang.gz"
RUN gunzip -f /opt/naivesystems/clang.gz
COPY "clang-tidy.gz" "/opt/naivesystems/clang-tidy.gz"
RUN gunzip -f /opt/naivesystems/clang-tidy.gz

COPY "clang-extdef-mapping" "/opt/naivesystems/clang-extdef-mapping"
COPY "clang-query" "/opt/naivesystems/clang-query"

COPY "misra_analyzer" "/opt/naivesystems/misra_analyzer"

COPY "bigmain_googlecpp" "/opt/naivesystems/bigmain"
COPY "bigmain_symlink" "/opt/naivesystems/bigmain_symlink"
RUN chmod +x /opt/naivesystems/bigmain_symlink && /opt/naivesystems/bigmain_symlink

COPY "google_cpp.check_rules.txt" "/opt/naivesystems/google_cpp.check_rules.txt"
COPY matcher.json /opt/naivesystems/matcher.json
COPY "github_printer" "/opt/naivesystems/github_printer"

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Specify the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

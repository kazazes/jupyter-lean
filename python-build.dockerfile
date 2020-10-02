FROM jupyter/base-notebook as nltk

WORKDIR /nltk_data
RUN pip install nltk
RUN python -m nltk.downloader -e -d /nltk_data popular
RUN python -m nltk.downloader -e -d /nltk_data vader_lexicon
RUN python -m nltk.downloader -e -d /nltk_data wordnet
RUN python -m nltk.downloader -e -d /nltk_data punkt


FROM jupyter/base-notebook as one
USER root
WORKDIR /build/src
RUN apt-get -qq update && apt-get install -y -q --no-install-recommends build-essential aria2

RUN aria2c -x4 -k1M \   
    "http://cdn.quantconnect.com/ta-lib/ta-lib-0.4.0-src.tar.gz" \
    "https://cdn.quantconnect.com/dx/dx-master-9fab393.zip" \
    "https://cdn.quantconnect.com/py-earth/py-earth-master-b209d19.zip" \
    "https://cdn.quantconnect.com/fastText/fastText-master-6d7c77c.zip" \
    "https://cdn.quantconnect.com/odo/odo-master-9fce669.zip" \
    "https://cdn.quantconnect.com/auto_ks/auto_ks-master-b39e8f3.zip" \
    "https://cdn.quantconnect.com/pyrb/pyrb-master-d02b56a.zip" \
    "https://cdn.quantconnect.com/ssm/ssm-master-34b50d4.zip" \
    "https://cdn.quantconnect.com/tigramite/tigramite-master-eee4809.zip" \
    "https://cdn.quantconnect.com/h2o/h2o-3.30.0.1.zip" 
# Install TA-lib for python
RUN tar -zxvf ta-lib-0.4.0-src.tar.gz && cd ta-lib && \
    ./configure --prefix=/build && make -j $(nproc) \ 
    && LDFLAGS="-L$PWD/include" make install
FROM one as two
    RUN pip install TA-lib && cd .. && rm -irf ta-lib

# Install DX Analytics
RUN unzip -q dx-master-9fab393 && cd dx-master && \
    python setup.py install --prefix=/build && cd .. && rm -irf dx-master

# Install py-earth
RUN unzip -q py-earth-master-b209d19.zip && cd py-earth-master && \
    python setup.py install --prefix=/build  && cd .. && rm -irf py-earth-master

# Install fastText
RUN unzip -q fastText-master-6d7c77c.zip && cd fastText-master && \
    python setup.py install --prefix=/build  && cd .. && rm -irf fastText-master

# Update ODO
RUN mamba remove --force-remove -y odo
RUN unzip -q odo-master-9fce669.zip && cd odo-master && \
    python setup.py install --prefix=/build  && cd .. && rm -irf odo-master

# Install Auto-KS

RUN unzip -q auto_ks-master-b39e8f3.zip && cd auto_ks-master && \
    python setup.py install --prefix=/build  && cd .. && rm -irf auto_ks-master

# Install Pyrb
RUN     unzip -q pyrb-master-d02b56a.zip && cd pyrb-master && \
    python setup.py install --prefix=/build  && cd .. && rm -irf pyrb-master

# Install SSM
RUN     unzip -q ssm-master-34b50d4.zip && cd ssm-master && \
    python setup.py install --prefix=/build  && cd .. && rm -irf ssm-master

# Install Tigramite
RUN     unzip -q tigramite-master-eee4809.zip && cd tigramite-master && \
    python setup.py install --prefix=/build  && cd .. && rm -irf tigramite-master

# Install H2O
RUN     unzip -q h2o-3.30.0.1.zip && \
    pip install --prefix=/build  h2o-3.30.0.1/python/h2o-3.30.0.1-py2.py3-none-any.whl && \
    rm -irf h2o-3.30.0.1
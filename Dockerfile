# Similar to QuantConnect's jupyter dockerfile, using the official jupyter server image as a base.
FROM jupyter/minimal-notebook as base
USER root

RUN  add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    r-base \
    pandoc \
    libcurl4-openssl-dev \
    openjdk-8-jdk openjdk-8-jre \
    sudo \
    cmake \
    zlib1g-dev \
    git bzip2 clang cmake curl unzip wget python3-pip python-opengl zlib1g-dev \
    xvfb libxrender1 libxtst6 libxi6 libglib2.0-dev libopenmpi-dev libstdc++6 openmpi-bin \
    && rm -rf /var/lib/apt/lists/*

# Unused
#FROM base as datasets
#WORKDIR /home/joyvan
#RUN pip install nltk
#RUN python -m nltk.downloader -e -d $PWD/nltk popular \
#    && python -m nltk.downloader -e -d $PWD/nltk vader_lexicon \
#    && python -m nltk.downloader -e -d $PWD/nltk wordnet \
#    && python -m nltk.downloader -e -d $PWD/nltk punkt

FROM base as conda-deps
USER 1000

# as of 10/20, this is as best as I could get to resolve
RUN conda create --name lean -c conda-forge -c fastai -c pytorch \
    python \
    ta-lib=0.4.19 \
    nvidia-ml=7.352.0 \
    jax=0.1.64 \
    cvxpy=1.1.5 \
    gplearn=0.4.1 \
    deap=1.3.1 \
    pykalman=0.9.5 \
    statsmodels=0.12.0 \
    xgboost=1 \
    pytorch=1.6.0 \
    fastai=1.0.61 \
    torchvision-cpu=0.2.2 \
    && conda clean -afy \
    && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
    && find /opt/conda/ -follow -type f -name '*.js.map' -delete

FROM base as jupyter-lean
COPY --from=conda-deps /opt/conda /opt/conda
USER 1000

# Install requirement for fbprophet
RUN pip install cmdstanpy==0.4
# Install from PIP I
RUN pip install arch==4.14 \
    copulalib==1.1.0 \
    copulas==0.3.0 \
    creme==0.5.1 \
    cufflinks==0.17.3 \
    gym==0.17.3 \
    ipywidgets==7.5.1

# Install from PIP II
RUN pip install \
    mlfinlab">==0.9.3" \
    pyportfolioopt==1.1.0 \
    pmdarima">==0.9.0" \
    pyro-ppl==1.3.1 \
    riskparityportfolio==0.1.6

# Install from PIP III
RUN pip install sklearn==0.0 \
    stable-baselines==2.10.0 \
    tensorforce==0.5.4 \
    QuantLib-Python==1.18 \
    statistics==1.0.3.5 \
    dtw-python==1.0.5

# Install from PIP IV
RUN pip install \
    mxnet==1.6 \
    gluonts==0.4.3 \
    jaxlib==0.1.45 \
    keras-rl==0.4.2 \
    pennylane==0.8.1

# Install Google Neural Tangents after JAX
RUN pip install --upgrade neural-tangents==0.2.1 mplfinance==0.12.3a3 hmmlearn==0.2.3

RUN jupyter labextension install jupyterlab_conda

# Install IB Gateway: Installs to ~/Jts
RUN wget http://cdn.quantconnect.com/interactive/ibgateway-stable-standalone-linux-x64-v978.2c.sh && \
    chmod 777 ibgateway-stable-standalone-linux-x64-v978.2c.sh && \
    ./ibgateway-stable-standalone-linux-x64-v978.2c.sh -q && \
    wget -O ~/Jts/jts.ini http://cdn.quantconnect.com/interactive/ibgateway-latest-standalone-linux-x64-v974.4g.jts.ini && \
    rm ibgateway-stable-standalone-linux-x64-v978.2c.sh

WORKDIR /home/joyvan/lean
RUN git clone https://github.com/QuantConnect/Lean.git
RUN cd Lean/PythonToolbox && python setup.py install
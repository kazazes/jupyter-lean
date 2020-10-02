# Similar to QuantConnect's jupyter dockerfile, but uses the official jupyter server
# image as a base.
# FROM python:3.6-slim as nltk-dataset
FROM jupyter/base-notebook as lead-deps
USER 1000
RUN conda config --set channel_priority strict &&     conda config --prepend channels conda-forge && conda config --set pip_interop_enabled True
RUN conda create --name lean -c conda-forge -c fastai -c pytorch  \
    mamba=0.5.3 "python<3.8a0" \
    ta-lib=0.4.19  \
    nvidia-ml=7.352.0 \
    pytorch=1.6.0 fastai=1.0.61 \
    torchvision-cpu=0.2.2 \
    cvxpy=1.1.5 \
    && conda clean -afy \
    && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
    && find /opt/conda/ -follow -type f -name '*.js.map' -delete

FROM jupyter/scipy-notebook
ENV DATASETS /home/joyvan/datasets

USER root

RUN apt-get update -qq && \ 
    apt-get install -y --no-install-recommends \
    r-base \
    pandoc \
    libcurl4-openssl-dev \
    openjdk-8-jdk openjdk-8-jre \
    sudo \
    cmake \
    zlib1g-dev \
    && rm -rf /var/apt/lists

USER 1000
RUN conda config --set channel_priority strict &&     conda config --prepend channels conda-forge && conda config --set pip_interop_enabled True
RUN conda create --name lean -c conda-forge -c fastai -c pytorch  \
    mamba=0.5.3 "python<3.8a0" \
    ta-lib=0.4.19  \
    nvidia-ml=7.352.0 \
    pytorch=1.6.0 fastai=1.0.61 \
    torchvision-cpu=0.2.2 \ 
    && conda clean -afy \
    && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
    && find /opt/conda/ -follow -type f -name '*.js.map' -delete 

# Install requirement for fbprophet
RUN pip install nltk cmdstanpy==0.4
RUN python -m nltk.downloader -e -d $PWD/nltk popular \
&& python -m nltk.downloader -e -d $PWD/nltk vader_lexicon \
&& python -m nltk.downloader -e -d $PWD/nltk wordnet \
&& python -m nltk.downloader -e -d $PWD/nltk punkt

# Install from PIP I
RUN pip install arch==4.14          \
    copulalib==1.1.0                \
    copulas==0.3.0                  \
    creme==0.5.1                    \
    cufflinks==0.17.3               \
    gym==0.17.1                     \
    ipywidgets==7.5.1

# Install from PIP II
RUN pip install deap==1.3.1         \
    cvxpy==1.1.5                    \
    mlfinlab>=0.9.3                 \
    pykalman==0.9.5                 \
    pyportfolioopt==1.1.0           \
    pmdarima>=0.9.0            \
    pyro-ppl==1.3.1                 \
    riskparityportfolio==0.1.6

# Install from PIP III
RUN pip install sklearn==0.0        \
    stable-baselines==2.10.0        \
    statistics==1.0.3.5             \
    statsmodels==0.11.1                \
    tensorforce==0.5.4              \
    QuantLib-Python==1.18           \
    xgboost==1.0.2                  \
    dtw-python==1.0.5

# Install from PIP IV
RUN pip install \
    mxnet==1.6                      \
    gluonts==0.4.3                  \
    gplearn==0.4.1                  \
    jax==0.1.64                     \
    jaxlib==0.1.45                  \
    keras-rl==0.4.2                 \
    pennylane==0.8.1

# Install Google Neural Tangents after JAX
RUN pip install neural-tangents==0.2.1

RUN pip install --upgrade mplfinance==0.12.3a3
RUN pip install --upgrade hmmlearn==0.2.3

RUN jupyter labextension install jupyterlab_conda

USER 1000
RUN git clone https://github.com/QuantConnect/Lean.git
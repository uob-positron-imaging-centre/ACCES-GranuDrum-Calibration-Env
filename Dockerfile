# Docker image containing all Binder configuration + PICI-LIGGGHTS + Python libraries
FROM anicusan/pici-liggghts:v3.8.1-focal


# Below adapted from https://github.com/pangeo-data/pangeo-docker-images/blob/master/base-image/Dockerfile - thank you Pangeo!
EXPOSE 8888
#ENTRYPOINT ["/srv/start"]
#CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]

# We use ONBUILD (https://docs.docker.com/engine/reference/builder/#onbuild)
# to support triggering certain behavior when specific files exist in the directories of our
# child images (such as base-notebook, pangeo-notebook, etc). For example,
# in pangeo-notebook/Dockerfile, we *only* inherit from base-image:master, and
# that triggers all these ONBUILD directives - it is as if these ONBUILD
# directives are located inside pangeo-notebook/Dockerfile. This lets us
# keep the Dockerfiles for our child docker images simple, and customize
# them by just adding files with known names to them. This is
# to *mimic* the repo2docker behavior, where users can just add
# environment.yml, requirements.txt, apt.txt etc files to get certain
# behavior without having to understand how Dockerfiles work. We use
# ONBUILD to support a subset of the files that repo2docker supports.
# We do not use repo2docker itself here, to make the images much smaller
# and easier to reason about.
# ----------------------
ONBUILD USER root
# FIXME (?): user and home folder is hardcoded for now
# FIXME (?): this line breaks the cache of all steps below
ONBUILD COPY --chown=dealii:dealii . /home/dealii

# repo2docker will load files from a .binder or binder directory if
# present. We check if those directories exist, and print a diagnostic
# message here.
ONBUILD RUN echo "Checking for 'binder' or '.binder' subfolder" \
        ; if [ -d binder ] ; then \
        echo "Using 'binder/' build context" \
        ; elif [ -d .binder ] ; then \
        echo "Using '.binder/' build context" \
        ; else \
        echo "Using './' build context" \
        ; fi

# If a jupyter_notebook_config.py exists, copy it to /etc/jupyter so
# it will be read by jupyter processes when they start. This feature is
# not available in repo2docker.
ONBUILD RUN echo "Checking for 'jupyter_notebook_config.py'..." \
        ; [ -d binder ] && cd binder \
        ; [ -d .binder ] && cd .binder \
        ; if test -f "jupyter_notebook_config.py" ; then \
        mkdir -p /etc/jupyter \
        && cp jupyter_notebook_config.py /etc/jupyter \
        ; fi

ONBUILD USER ${NB_USER}



#
# Vanilla Dockerfile for jupyter's python notebook
# for python developments
#

FROM jupyter/minimal-notebook

MAINTAINER cdeck3r


USER root

#
# add other things if required
#
RUN apt-get update && apt-get install -y \
   libxml2-dev libxslt-dev python-dev python3-lxml \
   default-jre \
   graphviz 

#
# Switch back to default user 
# 
USER $NB_UID
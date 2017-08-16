FROM centos:centos6
RUN mkdir -p /cfpb_app
COPY . /cfpb_app/
RUN ls -alh /cfpb_app
WORKDIR /cfpb_app
RUN yum install -y sudo
RUN source ./ansible_setup.sh
RUN source ./.docker_env; source ./.ansible_venv/bin/activate; ansible-playbook -i ansible/inventory -c local ansible/cfgov_refresh_setup.yml
CMD ["/bin/bash"]

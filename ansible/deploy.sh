#!/bin/bash
ansible-playbook -i inventory.yaml  playbook.yml
kubectl apply -f despliegue.yaml

#!/bin/bash

genisoimage -output cloud.iso -volid cidata -joliet -rock user-data meta-data
packer build template.json

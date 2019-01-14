# FRR for GNS3

Unofficial FRR VM image for GNS3.

## Building

Prerequisite softwares.

- Packer
- QEMU

Run Packer to build image.

```
packer build template.json
```

## Using

Create new QEMU VM template with built image and edit network settings.

- Adapters: 8
- Name Format: `eth{0}`

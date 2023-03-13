# RunPod Customizations

## Bootstrap Template

This is a technique to bootstrap a runpod image by using code in a template's "Docker Command" field. The recommended usage is to create a custom runpod template with this bootstrap. Then a pod can be created on this template, used, and stopped and deleted, stopping charges. The alternative to this would be to create a docker image containing safetensors etc, but this is more flexible at the expense of the bandwidth to bootstrap.

The Docker Command field:

```
bash -c ' rm -rf /workspace/LoRA; git clone https://github.com/lebowitz/LoRA.git /workspace/LoRA;
bash /workspace/LoRA/runpod_bootstrap.sh   '
```

The `runpod_bootstrap.sh` script installs various extensions. It also checks out specified commits for the webui and dreambooth extension. This is required to recreate a consistently working environment. Unfortunately `stable-diffusion-webui` and `sd-dreambooth-extension` aren't reliabily integrating with each other with the latest versions.

Environment variables:

- AWS_ACCESS_KEY_ID=*************
- AWS_SECRET_ACCESS_KEY=*************
- AUTHORIZED_KEY=ssh-ed25519 *************
- COMMIT_STABLE_DIFFUSION_WEBUI=c98cb0
- COMMIT_SD_DREAMBOOTH_EXTENSION=fd51c0
- MODELS_S3_URI=s3://*************

## Runpod.io Cost Control

The following cron line periodically stops all the pods running on runpod.io. This is a coarse but effective way to control costs.

`0    */3  * * * /home/ubuntu/runpod/runpodctl get pod | tail +2 | egrep RUNNING | cut -f 1 | xargs -r /home/ubuntu/runpod/runpodctl stop pod`

Todo: Use the `uptime` and `cpu` properties returned by the runpod graphql API to determine shutdown.

## Port Forward 3000

The `runpod_ssh.sh` script forwards port 3000 from the localhost to the pod using SSH. You can use http://localhost:3000 instead of gradio. This is more private because traffic is not routed through the reverse proxy.

Requires: 
 - The `runpodctl` utility. https://github.com/runpod/runpodctl
 - Setting the AUTHORIZED_KEY env variable in my template. This is what lets the local host authorize to the pod via SSH. The private key for this public key should exist on the local host at `~/.ssh/runpod.io`. 

## Upload to AWS S3 Bucket

I use a private S3 bucket with models that the bootstrap template syncs with the pod. Training data is also downloaded this way. See the `runpod_bootstrap.sh` script.

## kohya-ss/sd-scripts

The bootstrap script `runpod_bootstrap.sh` calls `runpod_sd_scripts.sh` which does a convoluted install of requirements for sd-scripts. Work in progress.

```
accelerate config 
#Answers to accelerate config: 
#This machine - No distributed training - NO - NO - NO - all - fp16 

accelerate launch --num_cpu_threads_per_process 24 train_network.py --pretrained_model_name_or_path=/workspace/stable-diffusion-webui/models/Stable-diffusion/v1-5-pruned.ckpt  --train_data_dir /workspace/stable-diffusion-webui/models/training/ --output_dir=/workspace/stable-diffusion-webui/models/Lora --output_name=$(date +%s)  --prior_loss_weight=1.0 --resolution=512 --train_batch_size=1 --learning_rate=1e-5 --max_train_steps=256 --xformers --mixed_precision=fp16 --save_every_n_epochs=1 --save_model_as=safetensors --clip_skip=2 --seed=$(date +%s) --color_aug --network_module=networks.lora --enable_bucket  
```

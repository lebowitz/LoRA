# RunPod

## Port Forward 3000

The `runpod_ssh.sh` script forwards port 3000 from the localhost to the pod using SSH. You can use http://localhost:3000 instead of gradio. This is more private because traffic is not routed through the reverse proxy.

Requires: 
 - The `runpodctl` utility 
 - Setting the AUTHORIZED_KEY env variable in my template. This is what lets the local host authorize to the pod via SSH.

# Dreambooth 

download 10 high quality jpg's 

paint.net, 
rec selection tool,  
fixed ratio option 512x512 
open each file 
frame the square 
ctrl-shift x - crop 
ctrl-s - save 
enter - save jpg 
now they are all square  

select files in explorer, right click windows image resize 

# Upload to AWS S3 Bucket

I use a private bucket which I sync with AWS.  

# kohya-ss/sd-scripts

The bootstrap script `runpod_bootstrap.sh` calls `runpod_sd_scripts.sh` which does a convoluted install of requirements for sd-scripts. Work in progress.

```
accelerate config 
#Answers to accelerate config: 
#This machine - No distributed training - NO - NO - NO - all - fp16 

accelerate launch --num_cpu_threads_per_process 24 train_network.py --pretrained_model_name_or_path=/workspace/stable-diffusion-webui/models/Stable-diffusion/v1-5-pruned.ckpt  --train_data_dir /workspace/stable-diffusion-webui/models/training/ --output_dir=/workspace/stable-diffusion-webui/models/Lora --output_name=$(date +%s)  --prior_loss_weight=1.0 --resolution=512 --train_batch_size=1 --learning_rate=1e-5 --max_train_steps=256 --xformers --mixed_precision=fp16 --save_every_n_epochs=1 --save_model_as=safetensors --clip_skip=2 --seed=$(date +%s) --color_aug --network_module=networks.lora --enable_bucket  
```
 




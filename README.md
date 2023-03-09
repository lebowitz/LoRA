# RunPod

## Port Forward 3000

```
SERVER=*****; PORT=****; ssh -L 3000:localhost:3000 -y -p $PORT -i ~/.ssh/runpod.io root@$SERVER 
```

Now you can use http://localhost:3000 instead of gradio. This is more private because traffic is not routed through gradio reverse proxy.

Replace the server and port with the values given in the RunPod Connect modal dialog.

This relies on setting the AUTHORIZED_KEY env variable in my template. 

# Dreambooth 

download 10 high quality jpg's 

paint.net, rec selection tool,  

fixed ratio option 512x512 

open each file 

frame the square 

ctrl-shift x - crop 

ctrl-s - save 

enter - save jpg 

now they are all square  



select files in explorer, right click windows image resize 

# Upload to AWS S3 Bucket

I use a private bucket which I sync with AWS at the 

 

pushd /workspace 

 

apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev zlib1g-dev lzma 
liblzma-dev python3-venv 

wget https://www.python.org/ftp/python/3.10.9/Python-3.10.9.tgz 
tar -xf Python-3.10.*.tgz 

cd Python-3.10.*/  

./configure --enable-optimizations 

make –j 16 # cpu core 
make altinstall 

 

popd 

 

git clone https://github.com/kohya-ss/sd-scripts 

 

pushd /workspace/sd-scripts 

rm -rf venv 
python3.10 -m venv venv 

source venv/bin/activate 

 

pip install --upgrade -r requirements.txt 

pip install xformers 

pip install triton 

 

accelerate config 

 

#Answers to accelerate config: 

#This machine - No distributed training - NO - NO - NO - all - fp16 

 

accelerate launch --num_cpu_threads_per_process 24 train_network.py --pretrained_model_name_or_path=/workspace/stable-diffusion-webui/models/Stable-diffusion/v1-5-pruned.ckpt  --train_data_dir /workspace/stable-diffusion-webui/models/training/ --output_dir=/workspace/stable-diffusion-webui/models/Lora --output_name=$(date +%s)  --prior_loss_weight=1.0 --resolution=512 --train_batch_size=1 --learning_rate=1e-5 --max_train_steps=256 --xformers --mixed_precision=fp16 --save_every_n_epochs=1 --save_model_as=safetensors --clip_skip=2 --seed=$(date +%s) --color_aug --network_module=networks.lora --enable_bucket  

 

popd 

 




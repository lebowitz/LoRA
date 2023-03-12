## In the RunPod Template, set the following keys:
## AWS_ACCESS_KEY_ID=*************
## AWS_SECRET_ACCESS_KEY=*************
## PRIVATE_KEY= -----BEGIN OPENSSH PRIVATE KEY----- ************* -----END OPENSSH PRIVATE KEY-----
## PUBLIC_KEY=ssh-ed25519 ************* eddsa-key-20230218
## AUTHORIZED_KEY=ssh-ed25519 ************* your_email@example.com
## COMMIT_STABLE_DIFFUSION_WEBUI=c98cb0
## COMMIT_SD_DREAMBOOTH_EXTENSION=fd51c0
## MODELS_S3_URI=s3://*************

## The Docker Command field should be:
## bash -c ' rm -rf /workspace/LoRA; git clone https://github.com/lebowitz/LoRA.git /workspace/LoRA;
## chmod +x /workspace/LoRA/runpod_bootstrap.sh
## /workspace/LoRA/runpod_bootstrap.sh   '

bash -c "DEBIAN_FRONTEND=noninteractive; 
apt update >> /workspace/log.txt;
apt install -y htop nano zip p7zip-full wget openssh-server net-tools --yes --quiet;
mkdir -p ~/.ssh;
chmod 700 ~/.ssh;
echo $AUTHORIZED_KEY >> ~/.ssh/authorized_keys;
echo $PRIVATE_KEY > ~/.ssh/id_rsa
chmod 700 ~/.ssh/authorized_keys ~/.ssh/id_rsa; 
service ssh start; 
cd /workspace/stable-diffusion-webui;

git pull;
git checkout $COMMIT_STABLE_DIFFUSION_WEBUI >> /workspace/log.txt
if [ ! -f /workspace/stable-diffusion-webui/aws/dist/aws ]; then     
echo 'Installing AWS CLI...';
curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip' >> /workspace/log.txt
unzip awscliv2.zip >> /workspace/log.txt
else  
echo 'AWS CLI exists.'; 
fi

ln -s /workspace/stable-diffusion-webui/aws/dist/aws /usr/bin/aws

aws configure set default.region us-east-1
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY

pushd /workspace/stable-diffusion-webui/models/Stable-diffusion
[ ! -f chilloutmix_Ni.safetensors ] && aws s3 cp $MODELS_S3_URI/Stable-diffusion/chilloutmix_Ni.safetensors . >> /workspace/aws_log.txt
[ ! -f v1-5-pruned.ckpt ] && aws s3 cp $MODELS_S3_URI/Stable-diffusion/v1-5-pruned.ckpt . >> /workspace/aws_log.txt
[ ! -f BstaberX.safetensors ] && aws s3 cp $MODELS_S3_URI/Stable-diffusion/BstaberX.safetensors . >> /workspace/aws_log.txt 
[ ! -f real_life_test.safetensors ] && aws s3 cp $MODELS_S3_URI/Stable-diffusion/real_life_test.safetensors . >> /workspace/aws_log.txt 
popd

aws s3 sync $MODELS_S3_URI/Stable-diffusion/Lora /workspace/stable-diffusion-webui/models/Lora/ >> /workspace/aws_log.txt
aws s3 sync $MODELS_S3_URI/Stable-diffusion/RealESRGAN /workspace/stable-diffusion-webui/models/RealESRGAN/ >> /workspace/aws_log.txt
aws s3 sync $MODELS_S3_URI/Stable-diffusion/training /workspace/stable-diffusion-webui/models/training/ >> /workspace/aws_log.txt

pushd /workspace/stable-diffusion-webui/extensions

[ ! -d stable-diffusion-webui-wildcards ] && git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-wildcards.git
[ ! -d sd-dynamic-prompts ] && git clone https://github.com/adieyal/sd-dynamic-prompts 
[ ! -d stable-diffusion-webui-images-browser ] && git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser
[ ! -d a1111-sd-webui-tagcomplete ] && git clone https://github.com/DominikDoom/a1111-sd-webui-tagcomplete
[ ! -d stable-diffusion-webui-tokenizer ] && git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-tokenizer
[ ! -d sd-webui-additional-networks ] && git clone https://github.com/kohya-ss/sd-webui-additional-networks
[ ! -d sd-webui-controlnet ] && git clone https://github.com/Mikubill/sd-webui-controlnet
[ ! -d sd_dreambooth_extension ] && git clone https://github.com/d8ahazard/sd_dreambooth_extension

popd
pushd /workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension; 
git checkout $COMMIT_SD_DREAMBOOTH_EXTENSION
popd
 
bash /workspace/LoRA/runpod_sd_scripts.sh &

export REQS_FILE=/workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension/requirements.txt
 
chmod +x /start.sh;
/start.sh;
sleep infinity"

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
## bash -c ' wget -O /workspace/stable-diffusion-webui/sd_runpod.sh https://raw.githubusercontent.com/lebowitz/LoRA/main/runpod_bootstrap.sh;
## chmod +x /workspace/stable-diffusion-webui/sd_runpod.sh  
## /workspace/stable-diffusion-webui/sd_runpod.sh   '

bash -c "DEBIAN_FRONTEND=noninteractive; 
apt update;
apt install -y htop nano zip p7zip-full wget openssh-server net-tools --yes --quiet;
mkdir -p ~/.ssh;
chmod 700 ~/.ssh;
echo $AUTHORIZED_KEY >> ~/.ssh/authorized_keys;
echo $PRIVATE_KEY > ~/.ssh/id_rsa
chmod 700 ~/.ssh/authorized_keys ~/.ssh/id_rsa; 
service ssh start; 
cd /workspace/stable-diffusion-webui;
git pull;
git checkout $COMMIT_STABLE_DIFFUSION_WEBUI
if [ ! -f awscliv2.zip ]; then     
echo 'Installing aws CLI...';
curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip';
unzip awscliv2.zip > /dev/null
else  
echo 'aws CLI exists.'; 
fi
 
alias aws=/workspace/stable-diffusion-webui/aws/dist/aws
/workspace/stable-diffusion-webui/aws/dist/aws configure set default.region us-east-1
#aws s3 sync $MODELS_S3_URI /workspace/stable-diffusion-webui/models/ &
/workspace/stable-diffusion-webui/aws/dist/aws s3 sync $MODELS_S3_URI/Stable-diffusion/v1-5-pruned.ckpt /workspace/stable-diffusion-webui/models/Stable-diffusion

pushd /workspace/stable-diffusion-webui/extensions
[ ! -d stable-diffusion-webui-wildcards ] && git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-wildcards.git
[ ! -d sd-dynamic-prompts ] && git clone https://github.com/adieyal/sd-dynamic-prompts 
[ ! -d stable-diffusion-webui-images-browser ] && git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser
[ ! -d a1111-sd-webui-tagcomplete ] && git clone https://github.com/DominikDoom/a1111-sd-webui-tagcomplete
[ ! -d stable-diffusion-webui-tokenizer ] && git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-tokenizer
[ ! -d sd-webui-additional-networks ] && git clone https://github.com/kohya-ss/sd-webui-additional-networks
[ ! -d sd-webui-controlnet ] && git clone https://github.com/Mikubill/sd-webui-controlnet
[ ! -d sd_dreambooth_extension ] && git clone https://github.com/d8ahazard/sd_dreambooth_extension
[ ! -d sd_civitai_extension ] && git clone https://github.com/civitai/sd_civitai_extension
popd
pushd /workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension; 
git checkout $COMMIT_SD_DREAMBOOTH_EXTENSION
popd
 
pip3 install --upgrade diffusers[torch] --quiet
pip3 install discord-webhook --quiet
pip3 install tensorflow --quiet
pip3 install accelerate==0.16 --quiet
pip3 install triton --quiet
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
pushd /workspace
apt install --quiet -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev zlib1g-dev lzma
liblzma-dev python3-venv
wget https://www.python.org/ftp/python/3.10.9/Python-3.10.9.tgz -O Python-3.10.9.tgz 
tar -xf Python-3.10.9.tgz --quiet
cd Python-3.10.9/
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
popd
apt-get --yes --quiet install liblzma-dev lzma
# recompile/install python??!!
# no idea but this hack is necessary to work around the missing _lzma module error popd
pushd /workspace/Python-3.10.9/
./configure --enable-optimizations
make –j 16 # cpu core
make altinstall
popd
 
export REQS_FILE=/workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension/requirements.txt
 
chmod +x /start.sh;
/start.sh;
sleep infinity"

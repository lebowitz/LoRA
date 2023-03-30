## In the RunPod Template, set the following keys:
## AWS_ACCESS_KEY_ID=*************
## AWS_SECRET_ACCESS_KEY=*************
## PRIVATE_KEY= -----BEGIN OPENSSH PRIVATE KEY----- ************* -----END OPENSSH PRIVATE KEY-----
## PUBLIC_KEY=ssh-ed25519 ************* eddsa-key-20230218
## AUTHORIZED_KEY=ssh-ed25519 ************* your_email@example.com
## COMMIT_STABLE_DIFFUSION_WEBUI=c98cb0
## COMMIT_SD_DREAMBOOTH_EXTENSION=fd51c0
## WORKSPACE_PASSWORD=<your password>
## S3_BUCKET=lebowitz

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

if [ ! -f /workspace/workspace.7z ]; then 
    echo 'Downloading workspace.7z...';
    aws s3 cp s3://$S3_BUCKET/workspace.7z /workspace/workspace.7z >> /workspace/aws_log.txt
    echo 'Extracting workspace.7z...';
    7z x /workspace/workspace.7z -o/workspace -p$WORKSPACE_PASSWORD -y -aoa >> /workspace/aws_log.txt
else
    echo 'workspace.7z exists.';
fi

pushd /workspace/stable-diffusion-webui/extensions

[ ! -d sd-dynamic-prompts ] && git clone https://github.com/adieyal/sd-dynamic-prompts 
[ ! -d stable-diffusion-webui-images-browser ] && git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser
[ ! -d a1111-sd-webui-tagcomplete ] && git clone https://github.com/DominikDoom/a1111-sd-webui-tagcomplete
[ ! -d sd-webui-additional-networks ] && git clone https://github.com/kohya-ss/sd-webui-additional-networks
[ ! -d sd-webui-controlnet ] && git clone https://github.com/Mikubill/sd-webui-controlnet
[ ! -d sd_dreambooth_extension ] && git clone https://github.com/d8ahazard/sd_dreambooth_extension
[ ! -d sd-webui-supermerger ] && git clone https://github.com/hako-mikan/sd-webui-supermerger
[ ! -d sd-extension-system-info ] && git clone https://github.com/vladmandic/sd-extension-system-info
[ ! -d stable-diffusion-webui-embedding-merge ] && git clone https://github.com/klimaleksus/stable-diffusion-webui-embedding-merge
[ ! -d stable-diffusion-webui-wd14-tagger ] && git clone https://github.com/toriato/stable-diffusion-webui-wd14-tagger
[ ! -d ultimate-upscale-for-automatic1111 ] && git clone https://github.com/Coyote-A/ultimate-upscale-for-automatic1111

popd

pushd /workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension; 
git checkout $COMMIT_SD_DREAMBOOTH_EXTENSION
popd

pushd /workspace
source venv/bin/activate
pip3 install -r stable-diffusion-webui/requirements.txt
pip3 install -r stable-diffusion-webui/extensions/sd_dreambooth_extension/requirements.txt 
popd

bash /workspace/LoRA/runpod_sd_scripts.sh

export REQS_FILE=/workspace/stable-diffusion-webui/extensions/sd_dreambooth_extension/requirements.txt
 
chmod +x /start.sh;
/start.sh;
sleep infinity"

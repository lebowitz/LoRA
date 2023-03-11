pushd /workspace

pip3 install --upgrade diffusers[torch] --quiet >> /workspace/log.txt
pip3 install discord-webhook --quiet >> /workspace/log.txt
pip3 install tensorflow --quiet >> /workspace/log.txt
pip3 install accelerate==0.16 --quiet >> /workspace/log.txt
pip3 install triton --quiet  >> /workspace/log.txt

apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev zlib1g-dev lzma  >> /workspace/log.txt
liblzma-dev python3-venv  >> /workspace/log.txt
wget https://www.python.org/ftp/python/3.10.9/Python-3.10.9.tgz  >> /workspace/log.txt
tar -xf Python-3.10.*.tgz  >> /workspace/log.txt

pushd Python-3.10.9/ 
./configure --enable-optimizations >> /workspace/log.txt
make –j 16  >> /workspace/log.txt
make altinstall  >> /workspace/log.txt
popd 

git clone https://github.com/kohya-ss/sd-scripts
pushd /workspace/sd-scripts
rm -rf venv
python3.10 -m venv venv  >> /workspace/log.txt
source venv/bin/activate
pip install --upgrade -r requirements.txt   >> /workspace/log.txt 
pip install xformers  >> /workspace/log.txt 
pip install triton  >> /workspace/log.txt
popd

# the sd_script fail with _lzma error if you don't do this part
apt-get --yes --quiet install liblzma-dev lzma >> /workspace/log.txt

# recompile/install python??!!
# no idea, but this hack is necessary to work around the missing _lzma module error popd

pushd /workspace/Python-3.10.9/
./configure --enable-optimizations  >> /workspace/log.txt
make –j 16  >> /workspace/log.txt
make altinstall  >> /workspace/log.txt
popd
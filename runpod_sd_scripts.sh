pushd /workspace

pip3 install --upgrade diffusers[torch] --quiet
pip3 install discord-webhook --quiet
pip3 install tensorflow --quiet
pip3 install accelerate==0.16 --quiet
pip3 install triton --quiet

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

# the sd_script fail with _lzma error if you don't do this part
apt-get --yes --quiet install liblzma-dev lzma

# recompile/install python??!!
# no idea, but this hack is necessary to work around the missing _lzma module error popd

pushd /workspace/Python-3.10.9/
./configure --enable-optimizations
make –j 16 # cpu core
make altinstall
popd
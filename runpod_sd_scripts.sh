pushd /workspace

pip3 install --upgrade diffusers[torch] --quiet >> /workspace/sd_scripts_log.txt
pip3 install discord-webhook --quiet >> /workspace/sd_scripts_log.txt
pip3 install tensorflow --quiet >> /workspace/sd_scripts_log.txt
pip3 install accelerate==0.16 --quiet >> /workspace/sd_scripts_log.txt
pip3 install triton --quiet >> /workspace/sd_scripts_log.txt

if [ ! -f /workspace/Python-3.10.9.tgz ]; then     

  apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev zlib1g-dev lzma  >> /workspace/log.txt
  liblzma-dev python3-venv >> /workspace/sd_scripts_log.txt
  wget --quiet https://www.python.org/ftp/python/3.10.9/Python-3.10.9.tgz >> /workspace/sd_scripts_log.txt
  tar -xf Python-3.10.9.tgz >> /workspace/sd_scripts_log.txt

  pushd Python-3.10.9

  ./configure --enable-optimizations >> /workspace/sd_scripts_log.txt
  make –j 16 >> /workspace/sd_scripts_log.txt
  make altinstall >> /workspace/sd_scripts_log.txt

  popd 

  rm -rf sd-scripts
  git clone https://github.com/kohya-ss/sd-scripts >> /workspace/sd_scripts_log.txt
  pushd /workspace/sd-scripts

  rm -rf venv
  python3.10 -m venv venv >> /workspace/sd_scripts_log.txt
  source venv/bin/activate >> /workspace/sd_scripts_log.txt

  pip install --upgrade -r requirements.txt >> /workspace/sd_scripts_log.txt 
  pip install xformers >> /workspace/sd_scripts_log.txt
  pip install triton >> /workspace/sd_scripts_log.txt

  popd

  # the sd_script fail with _lzma error if you don't do this part
  apt-get --yes --quiet install liblzma-dev lzma >> /workspace/sd_scripts_log.txt

  # recompile/install python??!!
  # no idea, but this hack is necessary to work around the missing _lzma module error popd

  pushd /workspace/Python-3.10.9/
  ./configure --enable-optimizations >> /workspace/sd_scripts_log.txt
  make –j 16 >> /workspace/sd_scripts_log.txt
  make altinstall >> /workspace/sd_scripts_log.txt
  popd

else

  echo "Python 3.10.9 already installed."

fi

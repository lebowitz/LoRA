#!/bin/bash

# pip uninstall xformers
cd ~/kohya_ss

python -m venv venv
source venv/bin/activate
#pip3 install -r requirements.txt
#pip3 install xformers

export BASE_MODEL=v1-5-pruned.safetensors
#export BASE_MODEL=realisticVisionV13_v13.safetensors

export STABLE_DIFFUSION_WEBUI="/home/ubuntu/stable-diffusion-webui"
export MODEL_NAME=$1
export REPEATS=${2:-50}

mkdir -v -p $STABLE_DIFFUSION_WEBUI/models/Lora/$MODEL_NAME
T=$(date +%s)

TMP=~/tmp/train-$T-$MODEL_NAME
mkdir -p $TMP
mkdir -p $TMP/training

cp -v ~/training/train.sh $TMP 
cp -v -r ~/training/$MODEL_NAME/* "$TMP/training"

pushd ~/kohya_ss
python finetune/make_captions.py $TMP/training
popd

KK_DIR=`echo $REPEATS`_`echo $MODEL_NAME`
mkdir -p $TMP/training_accept/$KK_DIR

cp -r -v $TMP/training/* $TMP/training_accept/$KK_DIR

#python ~/training/extract_faces.py $TMP/training_accept/$KK_DIR

find $TMP/training_accept -iname '*.jpg' -or -iname '*.png' > $TMP/training_filelist.txt

montage @$TMP/training_filelist.txt -label %f -geometry +4+4 $TMP/training-summary.jpg

python train_network.py \
     --network_module=networks.lora \
     --pretrained_model_name_or_path=$STABLE_DIFFUSION_WEBUI/models/Stable-diffusion/$BASE_MODEL \
     --train_data_dir=$TMP/training_accept \
     --output_dir=$STABLE_DIFFUSION_WEBUI/models/Lora/$MODEL_NAME \
     --prior_loss_weight=0.9 \
     --caption_extention=.txt \
     --resolution=512,512 \
     --network_dim=4 \
     --learning_rate=7e-5 \
     --lr_scheduler=constant \
     --mixed_precision="fp16" \
     --save_model_as="safetensors" \
     --save_precision="fp16" \
     --output_name=$MODEL_NAME \
     --max_train_steps=2000 \
     --cache_latents \
     --xformers \
     --train_batch_size=1 \
     --gradient_checkpointing \
     --logging_dir=$TMP/logs \
     --save_every_n_epochs=1
     # --reg_data_dir=$STABLE_DIFFUSION_WEBUI/training/hope/reg \
     #--use_8bit_adam \
     #--gradient_checkpointing \
     #--mem_eff_attn
     #--save_state \
     #--xformers 
     #--debug_dataset
     #--mem_eff_attn \
     #--save_every_n_epochs=1 \     
#     --enable_bucket \
#     --text_encoder_lr=1e-6 \

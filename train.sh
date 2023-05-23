#!/bin/bash

# pip uninstall xformers
cd ~/kohya_ss

python -m venv venv
source venv/bin/activate

export BASE_MODEL=v1-5-pruned.safetensors
export STABLE_DIFFUSION_WEBUI="/home/ubuntu/stable-diffusion-webui"
export MODEL_NAME=$1
export REPEATS=32

mkdir -v -p $STABLE_DIFFUSION_WEBUI/models/Lora/$MODEL_NAME
T=$(date +%s)

TMP=~/tmp/train-$T-$MODEL_NAME
mkdir -p $TMP
mkdir -p $TMP/training

cp -v ~/training/train.sh $TMP 
cp -v -r /home/ubuntu/training/$MODEL_NAME/* "$TMP/training"

# python ~/kohya_ss/finetune/make_captions.py $TMP/training

KK_DIR=`echo $REPEATS`_`echo $MODEL_NAME`
mkdir -p $TMP/training_accept/$KK_DIR
mkdir -p $TMP/training_reject

cp -r -v $TMP/training/* $TMP/training_accept/$KK_DIR

find $TMP/training_accept -iname '*.jpg' -or -iname '*.png' > $TMP/training_filelist.txt
montage @$TMP/training_filelist.txt -label %f -background '#336699' -geometry +4+4 $TMP/training_accept/training-summary.jpg

python train_network.py \
     --network_module=networks.lora \
     --pretrained_model_name_or_path=$STABLE_DIFFUSION_WEBUI/models/Stable-diffusion/$BASE_MODEL \
     --train_data_dir=$TMP/training_accept \
     --output_dir=$STABLE_DIFFUSION_WEBUI/models/Lora/$MODEL_NAME \
     --prior_loss_weight=0.9 \
     --resolution=512,512 \
     --network_dim=4 \
     --learning_rate=1e-4\
     --max_train_steps=5000 \
     --cache_latents \
     --mixed_precision="fp16" \
     --save_model_as="safetensors" \
     --output_name=$MODEL_NAME \
     --save_every_n_epochs=1
     --xformers \
     --use_8bit_adam \
     --gradient_checkpointing \
     #--mem_eff_attn
     #--save_state \
     #--xformers 
     #--debug_dataset
     #--mem_eff_attn \
     # --reg_data_dir=$STABLE_DIFFUSION_WEBUI/training/hope/reg \

/home/ubuntu/training/gen.sh realisticVisionV13_v13 $MODEL_NAME

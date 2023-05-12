#!/bin/bash

# pip uninstall xformers
cd ~/kohya_ss

python -m venv venv
source venv/bin/activate

export BASE_MODEL=v1-5-pruned.safetensors
export STABLE_DIFFUSION_WEBUI="/home/ubuntu/stable-diffusion-webui"
export MODEL_NAME=$1

mkdir -v -p $STABLE_DIFFUSION_WEBUI/models/Lora/$MODEL_NAME
T=$(date +%s)

TMP=~/tmp/train-$T
mkdir -p $TMP
mkdir -p $TMP/training

cp -v -r /home/ubuntu/training/$MODEL_NAME/* "$TMP/training"

# python ~/kohya_ss/finetune/make_captions.py $TMP/training

mkdir -p $TMP/training_accept/25_$MODEL_NAME
mkdir -p $TMP/training_reject

autocrop --input $TMP/training --output $TMP/training_accept/25_$MODEL_NAME  --width 512 --height 512 --no-confirm --reject $TMP/training_reject

python train_network.py \
     --network_module=networks.lora \
     --pretrained_model_name_or_path=$STABLE_DIFFUSION_WEBUI/models/Stable-diffusion/$BASE_MODEL \
     --train_data_dir=$TMP/training_accept \
     --output_dir=$STABLE_DIFFUSION_WEBUI/models/Lora/$MODEL_NAME \
     --prior_loss_weight=0.8 \
     --resolution=512,512 \
     --network_dim=4 \
     --learning_rate=3e-5\
     --max_train_steps=5000 \
     --cache_latents \
     --save_every_n_epochs=25 \
     --mixed_precision="fp16" \
     --save_model_as="safetensors" \
     --output_name=$MODEL_NAME \
     --use_8bit_adam \
     --gradient_checkpointing 
     #--mem_eff_attn
     #--save_state 
     #--xformers 
     #--debug_dataset
     #--mem_eff_attn 

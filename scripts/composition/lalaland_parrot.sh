#!/bin/bash

declare -A DATA_MASK_POSE_MAP
declare -A DATA_PROMPT_MAP

DATA_MASK_POSE_MAP["lalaland2"]="mask0 pose1"

DATA_PROMPT_MAP["lalaland2"]="a man dancing with a woman"


for DATA in "${!DATA_MASK_POSE_MAP[@]}"; do
    MASK_POSE=${DATA_MASK_POSE_MAP[$DATA]}
    MASK_POSES=($MASK_POSE)  # Convert string to array
    MASK=""
    for val in "${MASK_POSES[@]}"; do
        if [[ $val == mask* ]]; then
            MASK=$val
        else
            POSE=$val
            PROMPT=${DATA_PROMPT_MAP[$DATA]}
            INSTANCE_PROMPT="a photo of sks $PROMPT with parrot"
            GPU=0
            N_VIEWS=1

         
            FOLDER_NAME=baseline/composition/"$DATA"_parrot
            echo "Running with DATA=$DATA, POSE=$POSE, PROMPT=$PROMPT, INSTANCE_PROMPT=$INSTANCE_PROMPT"

            # Run the main command
            CUDA_VISIBLE_DEVICES=$GPU python enhancement.py \
                --config configs/image_sculpting.yaml \
                --test \
                --gpu $GPU \
                name=results/composition/lalaland_parrot \
                system.renderer.deformed_mesh="./runs/sculpting_data/$DATA/"$MASK"_resize.png/mesh/$POSE.obj" \
                system.renderer.original_mesh="./runs/sculpting_data/$DATA/"$MASK"_resize.png/mesh/model.obj" \
                system.model.instance_prompt="$INSTANCE_PROMPT" \
                system.model.lora_weights="./runs/dreambooth_ckpts/$DATA" \
                data.n_views=$N_VIEWS \
                system.inpainting.bg_path="./sculpting_data/$DATA/bg.png" \
                system.inversion.prompt="a photo of $PROMPT with parrot" \
                system.renderer.inserted_object="runs/3d_models/parrot.gltf"
        fi
    done
done
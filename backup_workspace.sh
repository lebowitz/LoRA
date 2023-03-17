pushd /workspace
find stable-diffusion-webui/embeddings/ stable-diffusion-webui/params.txt stable-diffusion-webui/ui-config.json stable-diffusion-webui/config.json stable-diffusion-webui/outputs stable-diffusion-webui/log stable-diffusion-webui/models -type f  -newer /workspace/workspace.7z > workspace_files.txt
export WORKSPACE_ARCHIVE=workspace-$(date +%s).7z
7z a -p -mhe -ir@"workspace_files.txt" $WORKSPACE_ARCHIVE
aws s3 cp $WORKSPACE_ARCHIVE s3://$S3_BUCKET/$WORKSPACE_ARCHIVE
popd

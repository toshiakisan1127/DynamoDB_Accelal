# bash
BUILD_LAMBDA_MODULE_DIR=package

# Recreate build directory
mkdir -p $BUILD_LAMBDA_MODULE_DIR

# Copy source files
echo "Copy source files"
cp -r ./../src/ $BUILD_LAMBDA_MODULE_DIR/

# Pack python libraries
echo "Pack python libraries"
pip install -r ./../src/requirements.txt -t ./$BUILD_LAMBDA_MODULE_DIR

# deploy lambda
terraform init
terraform apply --auto-approve -lock=false
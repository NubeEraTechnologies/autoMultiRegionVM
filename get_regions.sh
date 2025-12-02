#!/bin/bash

VM_SIZE="Standard_B2s_v2"
REQUIRED_COUNT=14

# Regions to exclude
EXCLUDE_REGIONS=(
  "swedencentral"
  "westus2"
  "indonesiacentral"
  "northeurope"
  "australiaeast"
  "westeurope"
  "eastasia"
  "southeastasia"
  "centralindia"
)

# Convert list to string for checking
EXCLUDE_STRING="${EXCLUDE_REGIONS[@]}"

echo "Filtering regions…"
echo "Excluded regions: ${EXCLUDE_STRING}"

ALL_REGIONS=$(az account list-locations --query "[].name" -o tsv)

AVAILABLE_REGIONS=()

for region in $ALL_REGIONS; do

    # Check if region is excluded
    if [[ " ${EXCLUDE_STRING[@]} " =~ " ${region} " ]]; then
        echo "⛔ Skipping excluded region: $region"
        continue
    fi

    # Check SKU availability
    SKU=$(az vm list-skus --location $region --size $VM_SIZE --query "[].name" -o tsv)

    if [[ ! -z "$SKU" ]]; then
        echo "✔ $region supports $VM_SIZE"
        AVAILABLE_REGIONS+=("$region")
    else
        echo "✖ $region does NOT support $VM_SIZE"
    fi
done

# Select first 14 free regions
SELECTED=("${AVAILABLE_REGIONS[@]:0:$REQUIRED_COUNT}")

# Write to tfvars file
echo "vm_regions = [" > regions.auto.tfvars
for r in "${SELECTED[@]}"; do
  echo "  \"$r\"," >> regions.auto.tfvars
done
echo "]" >> regions.auto.tfvars

echo ""
echo "========================================="
echo " Selected regions for VM deployment:"
printf '%s\n' "${SELECTED[@]}"
echo "========================================="

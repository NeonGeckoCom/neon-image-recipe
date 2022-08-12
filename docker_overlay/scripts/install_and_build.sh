#!/bin/bash
git clone https://github.com/neongeckocom/neon-image-recipe -b "${RECIPE_REF:-dev}"
bash neon-image-recipe/automation/build_image.sh
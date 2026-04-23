VERSION=1.14.4

# Télécharger
curl -L "https://github.com/GouvernementFR/dsfr/releases/download/v${VERSION}/dsfr-v${VERSION}.zip" -o dsfr.zip

unzip dsfr.zip \
  "dist/dsfr.min.css" \
  "dist/utility/utility.min.css" \
  "dist/dsfr.module.min.js" \
  "dist/dsfr.nomodule.min.js" \
  "dist/fonts/*" \
  "dist/icons/*" \
  "dist/favicon/favicon.svg" \
  -d tmp-dsfr

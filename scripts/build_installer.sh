#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "$BASH_SOURCE")/.."; pwd)"
source "$PROJECT_ROOT/scripts/env.sh"

INSTALLER_ROOT="$EXPORT_PATH/installer"

Version=`date "+%Y%m%d%H%M%S"`

if [[ $EXPORT_PATH == "" ]]
then
    echo "No Export Path Specificy"
    exit 1
fi
if [[ $INSTALLER_ROOT == "" ]]
then
    echo "No Installer Root Path Specificy"
    exit 1
fi

rm "$EXPORT_PATH/${TARGET}.pkg"
rm -rf "${INSTALLER_ROOT}"
mkdir -p "${INSTALLER_ROOT}"
cp -R "$EXPORT_PATH/${TARGET}.app" "${INSTALLER_ROOT}"
echo "INSTALLER_ROOT:"$INSTALLER_ROOT
echo "BUNDLE_IDENTIFIER:"$BUNDLE_IDENTIFIER
echo "INSTALL_LOCATION:"$INSTALL_LOCATION
echo "EXPORT_INSTALLER:"$EXPORT_INSTALLER

if [[ $USE_CODE_SIGN == "disable" ]]
then
    echo "build installer without signing"
    pkgbuild --info "${PROJECT_ROOT}/package/PackageInfo" \
    --root "${INSTALLER_ROOT}" \
    --identifier "${BUNDLE_IDENTIFIER}" \
    --version "${Version}" \
    --install-location "${INSTALL_LOCATION}" \
    --scripts "${PROJECT_ROOT}/package/scripts" \
    "$EXPORT_INSTALLER" || { echo "build installer failed"; exit 1; }
else
    pkgbuild --info "${PROJECT_ROOT}/package/PackageInfo" \
    --root "${INSTALLER_ROOT}" \
    --identifier "${BUNDLE_IDENTIFIER}" \
    --version "${Version}" \
    --install-location "${INSTALL_LOCATION}" \
    --scripts "${PROJECT_ROOT}/package/scripts" \
    --sign "Developer ID Installer: 373241884@qq.com" \
    "$EXPORT_INSTALLER" || { echo "build installer failed"; exit 1; }
fi

# pack zip for update
zip "$EXPORT_INSTALLER_ZIP" "$EXPORT_INSTALLER"

rm -rf "${ROOT_DIR}"

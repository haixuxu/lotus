#!/bin/bash


#find ./ -name "project.pbxproj"|xargs grep DEVELOPMENT_TEAM # get teamID


PROJECT_ROOT="$(cd "$(dirname "$BASH_SOURCE")/.."; pwd)"
TARGET="Lotus"
# PROJECT="$PROJECT_ROOT/${TARGET}.xcodeproj"
PROJECT="$PROJECT_ROOT/${TARGET}.xcworkspace"
APP_NAME="青青输入法"

BUNDLE_IDENTIFIER="com.xuxihai.inputmethod.Lotus"
INSTALL_LOCATION="/Library/Input Methods"

EXPORT_PATH="$PROJECT_ROOT/dist"
EXPORT_ARCHIVE="$EXPORT_PATH/archive.xcarchive"
EXPORT_APP="$EXPORT_PATH/$TARGET.app"
EXPORT_ZIP="$EXPORT_PATH/$TARGET.zip"
EXPORT_INSTALLER="$EXPORT_PATH/Lotus.pkg"
EXPORT_INSTALLER_ZIP="$EXPORT_PATH/Lotus.zip"

USE_CODE_SIGN="adhoc"

if [[ $USE_CODE_SIGN == "enable" ]]
then
    BUILD_FLAG=''
elif [[ $USE_CODE_SIGN == "adhoc" ]]
then
    # xcodebuild 阶段禁用签名，提取 .app 后再手动 ad-hoc 签名
    # 不能直接传 CODE_SIGN_IDENTITY="-"，会与 Xcode 自动签名冲突
    BUILD_FLAG='CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO'
elif [[ $USE_CODE_SIGN == "disable" ]]
then
    BUILD_FLAG='CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO'
fi

echo "BUILD_FLAG=$BUILD_FLAG"
echo "PROJECT_ROOT=$PROJECT_ROOT"
echo "EXPORT_PATH=$EXPORT_PATH"
echo "USE_CODE_SIGN=$USE_CODE_SIGN"

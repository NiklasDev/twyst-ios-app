//
//  Enums.h
//  Twyst
//
//  Created by Niklas Ahola on 5/2/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

typedef enum {
    DeviceTypePhone4 = 100,
    DeviceTypePhone5,
    DeviceTypePhone6,
    DeviceTypePhone6Plus,
} DeviceType;



typedef enum {
    FlipframeInputTypePhotoRegular = 0,
    FlipframeInputTypePhotoAuto = 1,
    FlipframeInputTypeVideo = 2,
} FlipframeInputType;



typedef enum {
    CameraCaptureTypeRegular,
    CameraCaptureTypeAuto,
} CameraCaptureType;



typedef enum {
    TwystShareOptionClosed = 0,         // public twyst. can not pass
    TwystShareOptionOpen,               // pulbic twyst. can pass
    TwystShareOptionPrivate,            // private twyst. can not pass. hidden from profile
} TwystShareOption;



typedef enum {
    FriendDataTypeNone = 0,
    FriendDataTypeFriend,
    FriendDataTypeRcvRequest,
    FriendDataTypeSearchResult,
    FriendDataTypeSentRequest,
} FriendDataType;



typedef enum {
    UserRelationTypeNone,
    UserRelationTypeFriend,
    UserRelationTypeRequested,
    UserRelationTypeReceived,
    UserRelationTypeSelf,
} UserRelationType;



typedef enum {
    BlurTypeNone = 0,
    BlurTypeRadial,
    BlurTypeLinear,
} BlurType;



typedef enum {
    Response_Success = 0,
    Response_NetworkError = 1,
    Response_Deleted_Twyst = 2,
    Response_Not_Twyster = 3,
} ResponseType;



typedef enum {
    // preview
    FullTutorialPreviewSkipFrame = 1000,
    FullTutorialPreviewSwipeUp,
    FullTutorialPreviewSwipeDown,
    FullTutorialPreviewSwipeLeft,
    FullTutorialPreviewSwipeRight,
    
    // camera screen
    FullTutorialCameraTapPhoto,
    FullTutorialCameraHoldVideo,
    FullTutorialCameraEcho,
    FullTutorialCameraReply,
    
    // edit screens
    FullTutorialEditPlayback,
    FullTutorialEditPhotoSwipeDown,
    FullTutorialEditVideoSwipeDown,
    
} FullTutorialType;



typedef enum {
    SlideUpTypeCameraAutoExit = 0,
    SlideUpTypeCameraAutoDelete,
    SlideUpTypeCameraRegularExit,
    SlideUpTypeCameraRegularDelete,
    
    SlideUpTypeEditExit,
    SlideUpTypeEditSendReply,
    SlideUpTypeEditAdvance,
    
    SlideUpTypeEditDrawRemove,
    SlideUpTypeEditDrawApplyAll,
    SlideUpTypeEditDrawRemoveAll,
    
    SlideUpTypeEditThemeExists,
    
    SlideUpTypeDeleteComment,
    SlideUpTypeDeleteTwyst,
    SlideUpTypeReportFrame,
    SlideUpTypeReportTwyst,
    SlideUpTypeRemoveMe,
    SlideUpTypePreviewMore,
    SlideUpTypePreviewMoreCreator,
    
    SlideUpTypeFriendsReply,
    SlideUpTypePrivateReply,
    SlideUpTypeOpenPassOnly,
    SlideUpTypeOpenPassAndReply,
    
    SlideUpTypeUnfriend,
    SlideUpTypeAddFriend,
    SlideUpTypeAcceptFriend,
    SlideUpTypeDeclineFriend,
    SlideUpTypeCancelRequest,
    SlideUpTypeAcceptDenyAllFriends,
    SlideUpTypeAcceptAllFriends,
    SlideUpTypeDeclineAllFriends,

} SlideUpType;



typedef NS_ENUM(int, WrongMessageType) {
    // register
    WrongMessageTypeInvalidEmailFormat = 1000,
    WrongMessageTypeInvalidPasswordFormat,
    WrongMessageTypeInvalidFirstName,
    WrongMessageTypeInvalidLastName,
    WrongMessageTypeUsernameLength,
    WrongMessageTypeUsernameOverLength,
    WrongMessageTypeUsernameInvalidFormat,
    WrongMessageTypeInvalidPhoneNumber,
    WrongMessageTypeVerificationCodeSent,
    WrongMessageTypeInvalidVerificationCode,
    WrongMessageTypeErrorExistingEmail,
    WrongMessageTypeErrorExistingUsername,
    WrongMessageTypeInvalidInviteCode,
    
    // forgot password
    WrongMessageTypeErrorEmailNotOnFile,
    WrongMessageTypeNewPasswordRequestSent,
    
    // login
    WrongMessageTypeInvalidCrediential,

    // edit profile
    WrongMessageTypeIncorrectOldPassword,
    WrongMessageTypeDoesNotMatchPassword,
    WrongMessageTypeItsTheSameAsTheOldPassword,
    WrongMessageTypeUploadProfileImageFailed,
    WrongMessageTypeUploadCoverImageFailed,
    WrongMessageTypeProfileChangesSaved,
    
    //edit twyst
    WrongMessageTypeDeleteFrames,
    WrongMessageTypeNeedOnePhoto,
    WrongMessageTypeTwystSaveLibrary,
    WrongMessageTypeSuccessSaveLibrary,
    WrongMessageTypeTwystDeleted,
    
    //comment
    WrongMessageTypeInvalidComment,
    WrongMessageTypeReportConfirmation,
    
    //share
    WrongMessageTypeCreateSuccessfully,
    WrongMessageTypeReplySuccessfully,
    WrongMessageTypePassSuccessfully,
    
    WrongMessageTypeRepliesOn,
    WrongMessageTypeRepliesOff,
    WrongMessageTypePassOn,
    WrongMessageTypePassOff,
    
    //global
    WrongMessageTypeTwystOverMaxFrames,
    WrongMessageTypeSuccessLeaveTwyst,
    
    //something went wrong
    WrongMessageTypeSomethingWentWrong,
    
    //no internet connection
    WrongMessageTypeNoInternetConnection,
};
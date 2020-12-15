//
//  SCAP.h
//  SCAP
//
//  Created by WangLi on 2017/5/15.
//  Copyright © 2017年 CFCA. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CFCA_OK             0
#define CFCA_ERROR          -1

typedef enum certType {
    CFCA_CERT_RSA1024 = 0,
    CFCA_CERT_RSA2048,
    CFCA_CERT_SM2
}CFCACertType;

typedef enum algType {
    CFCA_SYMMETRIC_ALGORITHAM_3DES_CBC = 0,
    CFCA_SYMMETRIC_ALGORITHAM_RC4,
    CFCA_SYMMETRIC_ALGORITHAM_SM4
}CFCAAlgType;

typedef enum hashType {
    CFCA_HASH_ALGORITHAM_SHA1 = 0,
    CFCA_HASH_ALGORITHAM_SHA256,
    CFCA_HASH_ALGORITHAM_SM3
}CFCAHashType;

typedef enum signType {
    CFCA_SIGN_TYEP_PKCS1 = 0,
    CFCA_SIGN_TYEP_PKCS7_A,
    CFCA_SIGN_TYEP_PKCS7_D
}CFCASignType;

typedef enum certUsage {
    CFCA_CERT_USAGE_SIGN = 1,
    CFCA_CERT_USAGE_ENCRYPT,
    CFCA_CERT_USAGE_SIGN_AND_ENCRYPT
}CFCACertUsage;

@interface SCAPCertificate : NSObject

@property (readonly) NSData         *certDer;//certificate der data
@property (readonly) NSString       *certBase64;//certificate base64 data
@property (readonly) NSString       *serialNumber;//certificate serial number
@property (readonly) NSString       *issuerDN;//DN of the pulish organization
@property (readonly) NSString       *subjectDN;//DN of the user
@property (readonly) NSString       *subjectCN;//CN of the user
@property (readonly) NSDate         *notBefore;//start date
@property (readonly) NSDate         *notAfter;//end date
@property (readonly) CFCACertType   certType;//certificate type
@property (readonly) CFCACertUsage  certUsage;//ceritificate usage

- (instancetype)initWithBase64CertData:(NSString *)base64CertData;
- (instancetype)initWithDerCertData:(NSData *)derCertData;

@end

@interface SCAP : NSObject

/*!
 @abstract   create SCAP object
 @result     [SCAP] instence
 */
+ (SCAP *)sharedSCAP;

/*!
 @abstract   get version of current app
 @result     [NSString] number of current app
 */
+ (NSString *)getVersion;

/*!
 @abstract   fetch all certificate
 @parameter  [NSArray **] list of all certificate
 @result     [NSInteger] error value, when fetch failure
 */
- (NSInteger)getAllCertificates:(NSArray **)certificates;

/*!
 @abstract   generate PKCS10 certificate request
 @parameter  [CFCACertType] certificate type
 @parameter  [BOOL] YES:double cert; NO:single cert
 @parameter  [NSString *] PIN value
 @parameter  [NSString **] base64 P10 value
 @result     [NSInteger] error value, when generateP10 failure
 */
- (NSInteger)generateP10:(CFCACertType)certType
            isDoubleCert:(BOOL)isDoubleCert
                 pinCode:(NSString *)pinCode
                     p10:(NSString **)base64P10;

/*!
 @abstract   import single certficate
 @parameter  [NSString *] single certificate content by Base64 encode
 @result     [NSInteger] error value, when import failure
 */
- (NSInteger)importSingleCertficate:(NSString *)base64Cert;

/*!
 @abstract   import double certficate
 @parameter  [NSString *] base64SignCert: sign certificate content by Base64 encode
 @parameter  [NSString *] base64EncryptCert: encrypt certificate content by Base64 encode
 @parameter  [NSString *] encryptedPrivateKey: encrypted private key for encrypt cert
 @result     [NSInteger] error value, when import failure
 */
- (NSInteger)importDoubleCertficate:(NSString *)base64SignCert
                        encryptCert:(NSString *)base64EncryptCert
                  encryptPrivateKey:(NSString *)encryptPrivateKey;

/*!
 @abstract   delete certificate
 @parameter  [SCAPCertificate *] certificate which will be deleted
 @result     [NSInteger] error value, when delete failure
 */
- (NSInteger)deleteCertificate:(SCAPCertificate *)certificate;

/*!
 @abstract   delete all certificate
 @parameter  void
 @result     [NSInteger] error value, when delete all certificates failure
 */
- (NSInteger)deleteAllCertificates;

/*!
 @abstract   change PIN value
 @parameter  [SCAPCertificate *] certificate which will be change
 @parameter  [NSString *] old PIN value
 @parameter  [NSString *] new PIN value
 @result     [NSInteger] error value, when change failure
 */
- (NSInteger)changePIN:(SCAPCertificate *)certificate
                oldPin:(NSString *)oldPin
                newPin:(NSString *)newPin;

/*!
 @abstract   digital sign
 @parameter  [SCAPCertificate *] certificate which be used to signing
 @parameter  [NSData *] content which will be signed
 @parameter  [NSString *] PIN value
 @parameter  [CFCAHashType] hash type   SHA1:0  SHA256:1   SM3:2
 @parameter  [CFCASignType] sign type   PKCS1:0  PKCS7_A:1  PKCS7_D:2
 @parameter  [NSString **]base64 signature data
 @result     [NSInteger] error value, when sign failure
 */
- (NSInteger)sign:(SCAPCertificate *)certificate
       dataToSign:(NSData *)dataToSign
              pin:(NSString *)pin
         hashType:(CFCAHashType)hashType
         signType:(CFCASignType)signType
        signature:(NSString **)base64Signature;

/*!
 @abstract   digital sign for hashed data(only PKCS#1)
 @parameter  [SCAPCertificate *] certificate which be used to signing
 @parameter  [NSString *] PIN value
 @parameter  [NSData *] hash data which will be signed
 @parameter  [CFCAHashType] hash type SHA1:0  SHA256:1   SM3:2
 @parameter  [CFCASignType] sign type   PKCS1:0 PKCS7_D:2 (not support PKCS7_A)
 @parameter  [NSString **]base64 signature data
 @result     [NSInteger] error value, when sign failure
 */
- (NSInteger)signHashData:(SCAPCertificate *)certificate
                      pin:(NSString *)pin
                 hashData:(NSData *)hashData
                 hashType:(CFCAHashType)hashType
                 signType:(CFCASignType)signType
                signature:(NSString **)base64Signature;

/*!
 @abstract   encrypt digital envelope
 @parameter  [NSData *] content which will be signed
 @parameter  [NSString *] public_key certificate with Base64 encode
 @parameter  [CFCAAlgType] encrypt algoritham   3DES:0  RC_4:1
 @parameter  [NSString **] encrypt data
 @result     [NSInteger] error value, when encrypt failure
 */
- (NSInteger)envelopeEncrypt:(NSData *)dataToEncrypt
                 certificate:(SCAPCertificate *)certificate
                symmetricAlg:(CFCAAlgType)algoritham
               encryptedData:(NSString **)base64EncryptedData;

/*!
 @abstract   get version of current app
 @parameter  [NSString *] public_key certificate with Base64 encode
 @parameter  [NSString *] PIN value
 @parameter  [NSString *] data which will be encrypted
 @parameter  [NSData **] plaint data
 @result     [NSInteger] error value, when encrypt failure
 */
- (NSInteger)envelopeDecrypt:(SCAPCertificate *)certificate
                         pin:(NSString *)pin
               dataEncrypted:(NSString *)base64EncryptedData
               decryptedData:(NSData **)decryptedData;

/*!
 @abstract   generate timestamp request data
 @parameter  [CFCAHashType]hashType: hash type. NOTE: now only suppot SHA1 and SHA256.
 @parameter  [NSData *]sourceData: source data
 @parameter  [NSData **]ppTimestampRequestData: data of timestamp request
 @result     [NSInteger] error value, when encrypt failure
 */
- (NSInteger)generateTimestampRequest:(CFCAHashType)hashType
                           sourceData:(NSData *)sourceData
                 timestampRequestData:(NSString **)base64TimestampRequestData;

/*!
 @abstract   update timestamp in PKCS7 signature
 @parameter  [NSData *]pkcs7SignatureData: PKCS7 signature data
 @parameter  [NSData *]timestampResponseData: data that is responsed by timestamp server
 @parameter  [NSData **]ppTimestampedPKCS7SignatureData: data that is signatured by timestamp server
 @result     [NSInteger] error value, when signature failure
 */
- (NSInteger)updataTimestampInPKCS7Signature:(NSData *)pkcs7SignatureData
                       timestampResponseData:(NSData *)timestampResponseData
               timestampedPKCS7SignatureData:(NSString **)base64TimestampedPKCS7SignatureData;

/*!
 @abstract   encode PKCS1 signature data to PKCS7 format
 @parameter  [NSData *]pkcs1SignatureData: PKCS1 signature data
 @parameter  [NSData *]timestampResponseData: data that is responsed by timestamp server
 @parameter  [NSData *]sourceData: source data
 @parameter  [BOOL]isAttach: flag of attaching source data. If the value is YES, parameter sourceData and sourceDataSize should be gave legal value.
 @parameter  [SCAPCertificate *]certificateData: signature certificate
 @parameter  [CFCAHashType]hashType: hash type. NOTE: now only support SHA1 and SHA256.
 @parameter  [NSData **]ppTimestampedPKCS7SignatureData: data that is signatured by timestamp server
 @result     [NSInteger] error value, when signature failure
 */
- (NSInteger)encodePKCS7SignatureWithTimestamp:(NSData *)pkcs1SignatureData
                         timestampResponseData:(NSData *)timestampResponseData
                                    sourceData:(NSData *)sourceData
                                isAttachSource:(BOOL)isAttach
                               certificateData:(SCAPCertificate *)certificateData
                                      hashType:(CFCAHashType)hashType
                 timestampedPKCS7SignatureData:(NSString **)base64TimestampedPKCS7SignatureData;

@end

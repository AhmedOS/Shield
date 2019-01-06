# 🛡Shield

### This app has three main functionalities:
- Scan file for viruses.
- Check if your email, account or password has been compromised in a data breach.
- Encrypt and decrypt files using a password.

<img src="https://i.imgur.com/iIDp45t.png" width="300">

### Scan File:

First, the user pick a file from his files to scan, then it get uploaded to be scanned. Next, the user can check scan report at the results tab. Scan report is persistent on the device once it get fetched.
This service is provided by VirusTotal API.

| <img src="https://i.imgur.com/6zT0Zo6.png" width="300"> | <img src="https://i.imgur.com/zq1R0kb.png" width="300"> |
| ------------------------------------------------------- | ------------------------------------------------------- |

### Data Breach:

Using haveibeenpwned database and API, the user can check if his email account or password has been compromised in a data breach or not. The process of checking for a compromised passwords is very secure and it doesn't send your password or its hash over the air, instead, it uses only the first five characters of its SHA-1 hash for the checking process. [How?](https://haveibeenpwned.com/API/v2#SearchingPwnedPasswordsByRange)

| <img src="https://i.imgur.com/yITnLKy.png" width="220"> | <img src="https://i.imgur.com/92n2Zcf.png" width="220"> | <img src="https://i.imgur.com/mEdXLa3.png" width="220"> |
| ------------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------- |

| <img src="https://i.imgur.com/dz6cbQY.png" width="300"> | <img src="https://i.imgur.com/AenWpsd.png" width="300"> |
| ------------------------------------------------------- | ------------------------------------------------------- |

### Files Encryption:
This feature allows a user to encrypt a file using a password and decrypt it later using the same password.
The SHA256 hash of a password is used as a key for the AES algorithm. Also, 128 of 256 bits from the key are used as an initialization vector for the AES. Encrypted and decrypted files are saved on the user device.

<img src="https://i.imgur.com/LHY6Fz6.png" width="300">

# Dependencies
#### CocoaPods:
```
pod 'Alamofire'
pod 'SwiftyJSON'
pod 'CryptoSwift'
```

# Disclaimer
Using this project in your "iOS Developer Nanodegree" will be considered as plagiarism, and it will lead to disqualifying you from the nanodegree.

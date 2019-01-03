# 🛡Shield

### This app has three main functionalities:
- Scan file for viruses.
- Check if your email, account or password has been compromised in a data breach.
- Encrypt and decrypt files using a password.


### Scan File:

First, the user pick a file from his files to scan, then it get uploaded to be scanned. Next, the user can check scan report at the results tab. Scan report is persistent on the device once it get fetched.
This service is provided by VirusTotal API.


### Data Breach:

Using haveibeenpwned database and API, the user can check if his email account or password has been compromised in a data breach or not. The process of checking for a compromised passwords is very secure and it doesn't send your password or its hash over the air, instead, it uses only the first five characters of its SHA-1 hash for the checking process. [How?](https://haveibeenpwned.com/API/v2#SearchingPwnedPasswordsByRange)


### Files Encryption:
This feature allows a user encrypt a file using a password and decrypt it later using the same password.
The SHA256 hash of a password is used as a key for the AES algorithm. Also, 128 of 256 bits from the key are used as an initialization vector for the AES. Encrypted and decrypted files are saved on the user device.


# Dependencies
#### CocoaPods:
Open terminal, then change directory to project root directory and execute `pod init`.
A pod file should be generated at project root directory, open it using a text editor and add these pods to it under `# Pods for Shield`:
```
pod 'Alamofire'
pod 'SwiftyJSON'
pod 'CryptoSwift'
```
Then save the file and close it. Now, execute `pod install` from terminal.
After it finish, `Shield.xcworkspace` file should exist, open it and build then run the project from there.

# Disclaimer
Using this project in your "iOS Developer Nanodegree" will be considered as plagiarism, and it will lead to disqualifying you from the nanodegree.

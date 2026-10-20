# Changelog

## 2.1.0.2-SNAPSHOT

- [LDEV-6120](https://luceeserver.atlassian.net/browse/LDEV-6120) — add javax and jakarta tags, so the extension can be run in Lucee 6 and 7
- Test case updates

## 2.1.0.1

- Add GAV coordinates to pom

## 2.1.0.0-BETA

- [LDEV-5901](https://luceeserver.atlassian.net/browse/LDEV-5901) — add attribute groups for CFZIP tag documentation
- Add TGZ and Tar Resource provider, compress and extract functions from core
- Add test cases for resource providers
- Fix manifest

## 2.0.0.3

- Release version for jakarta
- Use PageException instead of JSPException
- Set filter correct

## 2.0.0.0

- [LDEV-5383](https://luceeserver.atlassian.net/browse/LDEV-5383) — switch from javax to jakarta
- [LDEV-5753](https://luceeserver.atlassian.net/browse/LDEV-5753) — remove aesenc as a compressionMethod type
- [LDEV-5540](https://luceeserver.atlassian.net/browse/LDEV-5540) — fix cfzip compression level `deflateUtra` typo to `deflateUltra`
- Switch to Maven build script

## 1.0.0.15

- Update to zip4j 2.11.5

## 1.0.0.14

- [LDEV-4376](https://luceeserver.atlassian.net/browse/LDEV-4376) — update to zip4j 2.11.3

## 1.0.0.13

- [LDEV-4195](https://luceeserver.atlassian.net/browse/LDEV-4195) — update zip4j to 2.11.2

## 1.0.0.10

- [LDEV-4093](https://luceeserver.atlassian.net/browse/LDEV-4093) — update to zip4j 2.11.1

## 1.0.0.9

- [LDEV-4045](https://luceeserver.atlassian.net/browse/LDEV-4045) — update zip4j to 2.11.0

## 1.0.0.8

- [LDEV-3983](https://luceeserver.atlassian.net/browse/LDEV-3983) — update zip4j to 2.10.0

## 1.0.0.7

- [LDEV-3880](https://luceeserver.atlassian.net/browse/LDEV-3880) — fix cfzip filter delimiters to accept both pipe (`|`) and comma (`,`)
- [LDEV-3882](https://luceeserver.atlassian.net/browse/LDEV-3882) — fix pass full entry path to UDF for zip action delete
- [LDEV-2890](https://luceeserver.atlassian.net/browse/LDEV-2890) — fix zip add resource handling

## 1.0.0.6

- [LDEV-2660](https://luceeserver.atlassian.net/browse/LDEV-2660) — fix CFZIP `action="unzip"` `overwrite="true"` deleting existing directories

## 1.0.0.5

- [LDEV-3866](https://luceeserver.atlassian.net/browse/LDEV-3866) — fix zip action list filter entryPath using a UDF
- Use Lucee light for GHA tests

## 1.0.0.4

- Update zip4j to 2.9.0
- Add build and test workflow
- Add readme

## 1.0.0.3

- Add sourceUrl and documentionUrl
- Fix regression after updating jar
- Fix password issue caused by last change
- Update zip4j jar

## 1.0.0.2

- [LDEV-2320](https://luceeserver.atlassian.net/browse/LDEV-2320) — fix zip handling
- [LDEV-2117](https://luceeserver.atlassian.net/browse/LDEV-2117) — fix zip handling
- [LDEV-2223](https://luceeserver.atlassian.net/browse/LDEV-2223) — fix zip handling
- Enable compressionMethod
- Add missing attribute descriptions

## 1.0.0.x

- Initial commit

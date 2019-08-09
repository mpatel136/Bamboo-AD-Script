# Bamboo-AD-Script
A powershell script to extract information from Bamboo's API and update the users' information in Active Directory.

## Changes Needed in Script
1. Lines 292/295 can be commented/uncommented depending on whether or not you would like to show an error message indicating that the user was not found in the API.
2. Line 312 needs to be updated with the company's name which will go into the URL.
3. Line 315 needs to be updated with the company's name which will become the 'company' parameter in Active Directory.
4. Line 327 needs to be updated with a valid API key.

## Important Notes
1. The password on line 329 should remain as is.

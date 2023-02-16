# Python quickstart

Quickstarts explain how to set up and run an app that calls a Google Workspace API.

Google Workspace quickstarts use the API client libraries to handle some details of the authentication and authorization flow. We recommend that you use the client libraries for your own apps. Before you can run the sample app, each quickstart requires that you turn on authentication and authorization. If you're unfamiliar with authentication and authorization for Google Workspace APIs, read the  [Authentication and authorization overview](https://developers.google.com/workspace/guides/auth-overview?authuser=1).

Create a Python command-line application that makes requests to the Google Sheets API.

## Objectives

-   Set up your environment.
-   Install the client library.
-   Set up the sample.
-   Run the sample.

## Prerequisites

To run this quickstart, you need the following prerequisites:

-   Python 3.10.7 or greater
-   The  [pip](https://pypi.python.org/pypi/pip)  package management tool
-   [A Google Cloud project](https://developers.google.com/workspace/guides/create-project?authuser=1).

-   A Google Account.

## Set up your environment

To complete this quickstart, set up your environment.

### Enable the API

Before using Google APIs, you need to enable them in a Google Cloud project. You can enable one or more APIs in a single Google Cloud project.

-   In the Google Cloud console, enable the Google Sheets API.
    
    [ENABLE THE API](https://console.cloud.google.com/flows/enableapi?apiid=sheets.googleapis.com&authuser=1)
    

### Authorize credentials for a desktop application

To authenticate as an end user and access user data in your app, you need to create one or more OAuth 2.0 Client IDs. A client ID is used to identify a single app to Google's OAuth servers. If your app runs on multiple platforms, you must create a separate client ID for each platform.

1.  In the Google Cloud console, go to Menu  menu  >  **APIs & Services**  >  **Credentials**.
    
    [GO TO CREDENTIALS](https://console.cloud.google.com/apis/credentials?authuser=1)
2.  You will first need to configure consent screen, here
    -   Click  `CONFIGURE CONSENT SCREEN`
        -   Choose  `External`
        -   Fill out the required fields
    -   Scopes screen: just click  `Save and Continue`
    -   Test users screen:
        -   add test user email, use the same email as your google account
        -   click  `Save and Continue`    
3.  Click  **Create Credentials**  >  **OAuth client ID**.
4.  Click  **Application type**  >  **Desktop app**.
5.  In the  **Name**  field, type a name for the credential. This name is only shown in the Google Cloud console.
6.  Click  **Create**. The OAuth client created screen appears, showing your new Client ID and Client secret.
7.  Click  **OK**. The newly created credential appears under  **OAuth 2.0 Client IDs.**
8.  Save the downloaded JSON file as  `credentials.json`, and move the file to your working directory.

## Install the Google client library

-   Install the Google client library for Python:
    
    ```
    pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib
    ```
    

## Configure the sample

1.  In your working directory, create a file named  `quickstart.py`.
2.  Include the following code in  `quickstart.py`:
    
    sheets/quickstart/quickstart.py
    
    [VIEW ON GITHUB](https://github.com/googleworkspace/python-samples/blob/main/sheets/quickstart/quickstart.py) 
```py
from __future__ import print_function

import os.path

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
SCOPES = ['https://www.googleapis.com/auth/spreadsheets']

# The ID and range of a sample spreadsheet.
SAMPLE_SPREADSHEET_ID = '1XZZhjNjoPIn529vvwSmNMSqbW8Uf7iyabTfd35rZ0'
SAMPLE_RANGE_NAME = 'Class Data!A2:E'


def main():
    """Shows basic usage of the Sheets API.
    Prints values from a sample spreadsheet.
    """
    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            token.write(creds.to_json())

    try:
        service = build('sheets', 'v4', credentials=creds)

        # Call the Sheets API
        sheet = service.spreadsheets()
        result = sheet.values().get(spreadsheetId=SAMPLE_SPREADSHEET_ID,
                                    range=SAMPLE_RANGE_NAME).execute()
        values = result.get('values', [])

        if not values:
            print('No data found.')
            return

        print('Name, Major:')
        for row in values:
            # Print columns A and E, which correspond to indices 0 and 4.
            print('%s, %s' % (row[0], row[4]))
    except HttpError as err:
        print(err)


if __name__ == '__main__':
    main()
```
## Run the sample

1.  In your working directory, build and run the sample:
    
    ```
    python3 quickstart.py
    ```
    
2.  The first time you run the sample, it prompts you to authorize access:
    
    1.  If you're not already signed in to your Google Account, you're prompted to sign in. If you're signed in to multiple accounts, select one account to use for authorization.
    2.  Click  **Accept**.
    
    Authorization information is stored in the file system, so the next time you run the sample code, you aren't prompted for authorization.
    

You have successfully created your first Python application that makes requests to the Google Sheets API.

## Your working directory will contains token.json file
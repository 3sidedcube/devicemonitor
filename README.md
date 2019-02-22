<p align="center">
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-4.2-brightgreen.svg" alt="Swift 4.2">
    </a>
</p>

# Device Monitor API

Device monitor API is a simple server-side Swift API written for monitoring of test devices via an iOS or Android app installed on the device. The API has various endpoints for alerting for device changes. Device information is stored in a firebase realtime DB and updates can also be sent to Slack!

## Setup

### Setup Firebase

- Add a new project to your [firebase](https://console.firebase.google.com) account.
- Download your projects "Admin SDK" service account details (Settings → Service Accounts) from your new app, these will be used to give your project access to the realtime DB.
- Setup a realtime database **IMPORTANT**: do not use a Cloud Firestore as this project does not yet support this.
- Add users to your database, these should be setup like so:

```
"users": {
	"0": {
		"id": 0,
		"name": "Namey McNameFace",
		"slack": "User's slack username"   
	},
	"1": {
		"id": 1,
		"name": "Another Name",
		"slack": "username"	
	}
}
```
- Devices will be automatically added via the Android and iOS client.
- Setup for firebase [Cloud Messaging](https://firebase.google.com/docs/cloud-messaging/?authuser=0#implementation_paths): The API sends out `content-available` notifications to a "status" topic at regular intervals to make sure iOS devices (Which don't have great background capabilities) are kept up-to-date with the server.

### Setup Vapor

- [Install vapor](https://docs.vapor.codes/3.0/install/macos/) on your machine

### Setup Slack

You will need to have setup a slack app if you wish the API to post updates to your Slack account, and to enable a slash command which can be used to fetch device statuses. Follow the instructions [here](https://api.slack.com/incoming-webhooks#create_a_webhook) to set them up.

### Running

#### Environment Variables

The app depends on 6 environment variables:

| Variable Name | Value |
| ------------- | ----- |
| FIREBASE\_PRIVATE\_KEY | Base 64 encoded version of the private key downloaded from firebase. **Important:** Make sure to replace \n characters with actual line-breaks and to include the final linebreak before encoding |
| FIREBASE\_CLIENT\_EMAIL | The firebase client email from the file downloaded earlier |
| FIREBASE\_PROJECT\_ID | Your firebase project ID from the file downloaded earlier |
| FIREBASE\_DATABASE\_URL | The root url of your firebase realtime DB, this can be found in the firebase console. make sure to include the trailing slash! |
| SLACK\_WEBHOOK\_URL | The webhook url to post slack messages using |
| SLACK\_CHANNEL | The slack channel to post to: e.g. `#general`

These must be configured wherever you are running the server, be it on a local machine or a remote server. If `FIREBASE_PRIVATE_KEY` is not provided correctly the code will crash on launch.

#### Running locally

Either use vapor toolbox to run, in which case you will need to create environment variables

```
vapor build
vapor run
```

Or create an Xcode project

```
vapor xcode
```
and then run the "Run" scheme. If you are running in Xcode you can setup environment variables in the scheme settings.

#### Running Remotely

The easiest way to setup to run remotely is to use `vapor cloud`. Visit their [website](https://docs.vapor.cloud/quick-start/). It is important that you have [configured your environment variables](https://docs.vapor.cloud/configuration/vapor/custom-config/) otherwise you will receive 503 errors due to the crash mentioned above. At 3 Sided Cube we deployed to the alpha v2 version of vapor cloud as it provides a better interface and more features like custom docker files!

### Slack Command

Optionally you can setup a slack command to post back to a user the status of an individual or all devices. This command should be setup to `POST` to `{REMOTE_BASE_URL}/status` and can be setup to take a single parameter of the device name:

```
/devicestatus Foo's iPhone
```

Which will post to the channel used:

```
Foo's iPhone was last used by Foo World (Unplugged 🔌, Offsite 👋🏻)
```

## Endpoints

### Retrieve App Users

This is used by the client apps to allow users to login using their name as defined by the API when they unplug a test device.

**URL** : `users/`

**Method** : `GET`

**Response** : `200 OK`

```
[
	{
		"id": 0,
		"name": "Foo",
		"slack": "username"
	}
]
```

### Retrieve Devices

This isn't used by client apps but can be used to return a full list of devices.

**URL** : `devices/`

**Method** : `GET`

**Response** : `200 OK`

```
[
	{
		"id": 0,
		"name": "Foo's iPhone",
		"model": "iPhone 8 plus",
		"offsite": true,
		"pluggedIn": false,
		"seen": "2019-02-53T02:56:53+0000",
		"userId": 0,
		"batteryPercentage": 91
	}
]
```

### Silently Update Device

This endpoint can be used to silently update a particular device without posting to Slack about the change.

**URL** : `devices/{device_name}/`

**Method** : `PUT`

**Body** :

```
{
    "offsite": true
}
```

**Response** : `200 OK`

```
{
	"offsite": true,
	"seen": "2019-02-53T03:23:35+0000"
}
```
### Mark Device as Unplugged

This endpoint will mark the device as unplugged in Firebase and post to slack that the device was unplugged and who it was unplugged by (If provided in the body)

**URL** : `devices/{device_name}/unplugged`

**Method** : `POST`

**Body** :

```
{
    "userId": 0 // Optional! Will pull user's name from DB and include it with slack message if provided
}
```

**Response** : `200 OK`

```
{
	"userId": 0,
	"seen": "2019-02-53T03:23:35+0000",
	"pluggedIn": false
}
```

### Mark Device as Plugged In

This endpoint will mark the device as plugged in in Firebase and post to slack that the device was unplugged and who it was unplugged by (If provided in the body)

**URL** : `devices/{device_name}/pluggedIn`

**Method** : `POST`

**Body** :

```
{
    "userId": 0 // Optional! Will pull user's name from DB and include it with slack message if provided
}
```

**Response** : `200 OK`

```
{
	"userId": 0,
	"seen": "2019-02-53T03:23:35+0000",
	"pluggedIn": true
}
```

### Mark Device as "Onsite"

This endpoint will mark the device as having been returned to a place of work or other significant location and post to slack with the update

**URL** : `devices/{device_name}/onsite`

**Method** : `POST`

**Body** :

```
{
    "userId": 0 // Optional! Will pull user's name from DB and include it with slack message if provided
}
```

**Response** : `200 OK`

```
{
	"userId": 0,
	"seen": "2019-02-53T03:23:35+0000",
	"offsite": false
}
```

### Mark Device as "Offsite"

This endpoint will mark the device as having been moved away from a place of work or other significant location and post to slack with the update

**URL** : `devices/{device_name}/offsite`

**Method** : `POST`

**Body** :

```
{
    "userId": 0 // Optional! Will pull user's name from DB and include it with slack message if provided
}
```

**Response** : `200 OK`

```
{
	"userId": 0,
	"seen": "2019-02-53T03:23:35+0000",
	"offsite": false
}
```

### Mark Device as being low on battery

This endpoint will update the battery percentage of the device on the server and send a message to slack that it is getting low on battery

**URL** : `devices/{device_name}/low_battery`

**Method** : `POST`

**Body** :

```
{
    "userId": 0 // Optional! Will pull user's name from DB and include it with slack message if provided
    "batteryPercentage": 7
}
```

**Response** : `200 OK`

```
{
	"userId": 0,
	"seen": "2019-02-53T03:23:35+0000",
	"batteryPercentage": 7
}
```

### Check for unseen devices

This endpoint will check the last "seen" time of each device and post to slack if some devices haven't been seen within the last 2 hours. This is called locally by the server every hour.

**URL** : `devices/check`

**Method** : `POST`

**Body** : `Empty Body`

**Response** : `200 OK` (An array of devices which haven't been seen in 2 hrs)

```
[
	{
		"id": 0,
		"name": "Foo's iPhone",
		"model": "iPhone 8 plus",
		"offsite": true,
		"pluggedIn": false,
		"seen": "2019-02-53T02:56:53+0000",
		"userId": 0,
		"batteryPercentage": 91
	}
]
```
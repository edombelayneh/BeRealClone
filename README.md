# Project 3 - **BeReal Clone**

Submitted by: **Edom Belayneh**

**BeReal Clone** is an iOS app that introduces authentic social sharing by prompting users to capture and upload a photo from their **front and back camera once per day**. Users can only see friends’ posts after they share their own, encouraging real-time posting and genuine connection. The app also supports comments, location tagging, and time tracking for each post.

Time spent: **15 hours** spent in total

## Required Features

The following **required** functionality is completed:

- [x] User can launch the **camera** to take a photo instead of selecting from the photo library
- [x] Users are not able to see other users’ photos until they upload their own
- [x] Users can interact with posts via **comments**, which include user data such as username and name
- [x] Posts have both **time** and **location** metadata attached to them
- [x] Users cannot view others’ photos until they post their own (within 24 hours)

## Optional Features

The following **optional** features are implemented:

* [ ] Users receive a **notification reminder** when it’s time to post
* [ ] Pull-to-refresh feed
* [x] Persistent login session using Parse


## Additional Features

* [x] Posts display image metadata such as date taken and geocoded city/state
* [x] Reverse-geocoding converts GPS EXIF data into readable locations
* [x] Integrated **ParseSwift** for backend storage and user management
* [x] Each post supports multiple comments stored and fetched via pointers
* [x] Clean, modern UI using UIKit and Auto Layout
* [x] Works with both physical device and simulator

## Video Walkthrough

https://github.com/user-attachments/assets/1ddd5005-654a-4618-aab7-4dd70d2c8b28


## Notes

Some challenges encountered while building the app included:

* Debugging Parse object relationships so each comment correctly pointed to its associated post.
* Extracting and decoding EXIF metadata for GPS coordinates and timestamps.
* Handling camera permissions and fallbacks for simulator users.
* Managing the 24-hour visibility logic for posts.


## License

```
Copyright 2025 Edom Belayneh

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

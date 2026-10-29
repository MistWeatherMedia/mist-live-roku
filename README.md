<h1 align="center">Mist Live - Roku Client</h1>

<h3 align="center">An official Roku TV client for <a href="https://mistlive.tv/">Mist Live</a>, letting viewers browse and watch live streams directly on their TV.</h3>

## Channel Grid
<img width="1280" height="720" alt="image" src="https://github.com/user-attachments/assets/b2c12244-8e8d-4cc8-b216-faefa92c36db" />

- Every active channel in one row, sorted alphabetically
- Channel title, live viewer count, and description for the highlighted channel
- "Now" and "Next" program info for channels that support scheduling
- Favorites: favorite channels appear first, divided by a divider, and then the full channel list.

## Video player
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/5ea4d754-1a26-4e19-af71-096c08a4ad02" />

- **Closed captions**, for streams that support captions
- **Settings**:
  - **Favorites:** add or remove the channel you're watching
  - **Sleep Timer:** 30, 60, 90, 120, 180 or 240 minutes. A countdown appears for the last 30 seconds, any button cancels it.
  - **Stream Info:** resolution, bitrate, connection speed, buffering state, uptime, and device details, handy when reporting a problem

## Using the app

| Button | In the guide | While watching |
|---|---|---|
| **Left / Right** | Move between channels | Moves between the caption and settings icons |
| **Up** | | Clears the highlight |
| **OK** | Play the highlighted channel | Activates the highlighted icon |
| **Back** | Exits the app | Returns to the guide (closes the settings panel first if it's open) |
| **Any button** | | Shows the overlay if it has faded |

## Installing Mist Live on Your Roku - Channel Store
Navigate to the [Roku Channel Store](https://channelstore.roku.com/details/ab88d14056ce4aafd21b1282bcdbd552:67ae789bb69008018a61fb4bdbf156e8/mist-live), and search up "Mist Live", and press "Add App" to easily install it.

## Installing Mist Live on Your Roku - Sideloading

### Step 1: Enable Developer Mode

1. On your Roku remote, make sure you're on the **Home screen**.
2. Press these buttons in order, with a short pause between each:
   - **Home** (press it **3 times**)
   - **Up** (press it **2 times**)
   - **Right**
   - **Left**
   - **Right**
   - **Left**
   - **Right**
3. A screen called **"Developer Application Installer"** should appear.
4. The first time you do this, it'll ask you to set a **username and password** — the username will already be filled in as `rokudev`. Pick a password and remember it (write it down if needed).
5. This screen will also show your Roku's **IP address**, something like `192.168.1.XX`. Write that down too.

> If you ever restart your Roku and this screen doesn't come back automatically, you can always re-enter developer mode by repeating the button sequence above.

### Step 2: Get the app file

Download the latest `Mist Live.zip` from the [Releases](../../releases) page.

### Step 3: Upload it to your Roku

1. On a computer or phone connected to the **same Wi-Fi network** as your Roku, open a web browser.
2. Go to `http://` followed by the IP address from Step 1 (example: `http://192.168.1.42`).
3. Log in with:
   - Username: `rokudev`
   - Password: whatever you set in Step 1
4. You'll see an **"Application Installer"** page. Look for an **Upload** button or file picker.
5. Select `Mist Live.zip` and click **Install**.
6. Give it a few seconds — the Roku screen should switch over and launch Mist Live automatically.

## Troubleshooting

- **Can't find the IP address / installer page won't load:** Double-check your computer/phone and Roku are on the same Wi-Fi network.
- **No captions:** Not every stream carries captions, please check out the same stream on [mistlive.tv](https://mistlive.tv) if you're not sure. Caption appearance (size, color, font) is controlled by your Roku's own caption settings.
- **No "Now / Next" info on a channel:** Not every channel publishes a schedule, so most channels will simply not show those lines.
- **Install fails or app crashes:** Open an issue on this repo, or create a ticket in the [Mist Live Discord](https://discord.gg/KcAccNaJ7a) with a description of what happened. A photo or video of it happening helps. If you're reporting a playback problem, turn on **Stream Info** in the settings panel and include what it shows.

## Development

This app is built with the Roku SceneGraph SDK (BrightScript, XML). To work on it yourself:

1. Clone this repo
2. Open it in VS Code with the [BrightScript Language extension](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript)
3. Connect to a Roku device in Developer Mode (see install steps above)
4. Press `F5` to deploy to the device and see the debug console

## License

This project is a fork of [weatherranch/channels](https://github.com/weatherranch/channels), licensed under **GPL-3.0**. This fork is distributed under the same license. See [LICENSE](./LICENSE) for details.

## Disclaimer

Most Streams and channel content are provided by members of Mist Live; this project only provides the Roku client for browsing and viewing them.

## Contact

Questions or issues:
Join the [Mist Live Discord Server](https://discord.gg/KcAccNaJ7a), and make a ticket, or contact me via email at [rukasu@mistwx.com](mailto:rukasu@mistwx.com)

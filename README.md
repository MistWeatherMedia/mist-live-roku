<h1 align="center">Mist Live - Roku Client</h1>

<p align="center">
  <strong>An official Roku TV client for <a href="https://mistlive.tv/">Mist Live</a>, letting viewers browse and watch live streams directly on their TV.</strong>
</p>

---

## Features

### Channel Grid
<img width="1280" height="720" alt="Channel Grid" src="https://github.com/user-attachments/assets/835c6f1f-8bed-4deb-b7ca-4d18a55a1801" />

- **Sorted Alphabetically:** Every active channel is displayed in a single row sorted alphabetically.
- **Channel Details:** Displays the channel title, live viewer count, and description for the highlighted channel.
- **Program Guide:** Shows **"Now"** and **"Next"** program info for channels that support scheduling.
- **Favorites:** Favorite channels appear first, separated from the full channel list by a divider.

### Video Player
<img width="1920" height="1080" alt="Video Player" src="https://github.com/user-attachments/assets/5ea4d754-1a26-4e19-af71-096c08a4ad02" />

- **Closed Captions:** Available for streams that support captions.
- **Settings Menu:**
  - **Favorites:** Add or remove the channel you are currently watching.
  - **Sleep Timer:** Set a timer for 30, 60, 90, 120, 180, or 240 minutes. A countdown appears during the final 30 seconds, pressing any button cancels it.
  - **Stream Info:** Displays resolution, bitrate, connection speed, buffering state, uptime, and device details (helpful when reporting issues).

---

## Controls

| Button | In the Guide | While Watching |
| :--- | :--- | :--- |
| **Left / Right** | Moves between channels | Moves between the caption and settings icons |
| **Up** | — | Clears the highlight |
| **OK** | Plays the highlighted channel | Activates the highlighted icon |
| **Back** | Exits the app | Closes the settings panel if open, or returns to the guide |
| **Star (`*`)** | Opens a Channel ID dialog to play unlisted/private channels | Opens Roku's default options menu |
| **Any Button** | — | Shows the player overlay if it has faded |

---

## Installation

### Option 1: Roku Channel Store (Recommended)
1. Go to the [Roku Channel Store](https://channelstore.roku.com/details/ab88d14056ce4aafd21b1282bcdbd552:67ae789bb69008018a61fb4bdbf156e8/mist-live) or search for **"Mist Live"** on your Roku.
2. Select **Add App** to install.

### Option 2: Sideloading

#### Step 1: Enable Developer Mode
1. Navigate to the **Home screen** on your Roku.
2. On your remote, press the following buttons in order with a short pause between each:
   - **Home** (3 times)
   - **Up** (2 times)
   - **Right**, **Left**, **Right**, **Left**, **Right**
3. The **Developer Application Installer** screen will appear.
4. If this is your first time, set a password for the pre-filled username (`rokudev`) and write it down.
5. Note your Roku's **IP address** shown on screen (e.g., `192.168.1.XX`).

> **Note:** If you restart your Roku and this screen does not reappear automatically, repeat the button sequence above to re-enter Developer Mode.

#### Step 2: Download the App
Download the latest `Mist Live.zip` from the [Releases](../../releases) page.

#### Step 3: Upload to Your Roku
1. On a computer or phone connected to the **same Wi-Fi network** as your Roku, open a web browser.
2. Navigate to `http://` followed by your Roku's IP address from Step 1 (e.g., `http://192.168.1.42`).
3. Log in using:
   - **Username:** `rokudev`
   - **Password:** *(The password you created in Step 1)*
4. On the **Application Installer** page, click **Upload** (or the file picker) and select `Mist Live.zip`.
5. Click **Install**. After a few seconds, your Roku will automatically launch Mist Live.

---

## Troubleshooting

- **Can't find the IP address or the installer page won't load:** Verify that your computer/phone and your Roku are connected to the exact same Wi-Fi network.
- **No captions appearing:** Not every stream carries captions. Check the same stream on [mistlive.tv](https://mistlive.tv) to confirm if captions are available. Caption appearance (size, color, and font) is controlled by your Roku's system settings.
- **No "Now / Next" info on a channel:** Most channels do not publish schedules, so those lines will remain hidden for unsupported channels.
- **Installation fails or app crashes:** Open an issue in this repository or create a ticket in the [Mist Live Discord](https://discord.gg/KcAccNaJ7a) with a description (and photo/video if possible) of what happened. For playback issues, please enable **Stream Info** in the settings panel and include the displayed details.

---

## Development

This app is built using the Roku SceneGraph SDK (BrightScript and XML). To build and run it locally:

1. Clone this repository.
2. Open the project in VS Code with the [BrightScript Language extension](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript).
3. Connect to a Roku device with Developer Mode enabled (see sideloading steps above).
4. Press `F5` to deploy the app to your device and view the debug console.

---

## License & Disclaimer

- **License:** This project is a fork of [weatherranch/channels](https://github.com/weatherranch/channels) and is distributed under the same **GPL-3.0** license. See [LICENSE](./LICENSE) for details.
- **Disclaimer:** Most streams and channel content are provided by members of Mist Live. This project solely provides the Roku client for browsing and viewing them.

---

## Contact

For questions or support:
- Join the [Mist Live Discord Server](https://discord.gg/KcAccNaJ7a) and open a ticket.
- Email: [rukasu@mistwx.com](mailto:rukasu@mistwx.com)

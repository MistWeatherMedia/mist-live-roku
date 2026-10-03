# Mist Live - Roku Client

An official Roku client for [Mist Live](https://mistlive.tv/), letting viewers browse and watch live streams directly on their TV.

<img width="1280" height="720" alt="image" src="https://github.com/user-attachments/assets/c2cdf7d4-52e8-4c08-8108-2d1567aeb0e4" />


## Installing Mist Live on Your Roku - Channel Store
Navigate to the Roku Channel Store, and search up "Mist Live", and press Add App to easily install it.

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

### If something goes wrong

- **Can't find the IP address / installer page won't load:** Double-check your computer/phone and Roku are on the same Wi-Fi network.
- **Install fails or app crashes:** Open an issue on this repo (or contact me directly) with a description of what happened. A photo of the error helps.

## Development

This app is built with the Roku SceneGraph SDK (BrightScript, XML). To work on it yourself:

1. Clone this repo
2. Open it in VS Code with the [BrightScript Language extension](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript)
3. Connect to a Roku device in Developer Mode (see install steps above)

## License

This project is a fork of [weatherranch/channels](https://github.com/weatherranch/channels), licensed under **GPL-3.0**. This fork is distributed under the same license. See [LICENSE](./LICENSE) for details.

## Disclaimer

Streams and channel content are provided by Mist Weather Media; this project only provides the Roku client for browsing and viewing them.

## Contact

Questions or issues:
[Rukasu Development Server](https://discord.gg/3KvxYqpYdF) on Discord or
[rukasu@mistwx.com](mailto:rukasu@mistwx.com)

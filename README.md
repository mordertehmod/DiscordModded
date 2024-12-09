# BunnyTweak

![screenshot](https://adriancastro.dev/c6wkhfl0rq1f.PNG)

Tweak to inject [Bunny](https://github.com/pyoncord/Bunny) and [OpenInDiscord](https://github.com/castdrian/OpenInDiscord) into Discord. Forked from [VendettaTweak](https://github.com/vendetta-mod/VendettaTweak) and modified to match with [BunnyXposed](https://github.com/pyoncord/BunnyXposed)'s behavior.

<details>
<summary>Amended Licensing Terms Notice</summary>

As of commit b7cd1471f7d9dd79fe7832e7e7face296f2fd6a6, this repository includes an amendment to the original Open Software License 3.0 ("OSL 3.0"). The following new conditions have been added to the license:

- Substantial Modification Requirement: Any forks, derivative works, or redistributions of this project must meet the requirement for substantial modification as outlined in the updated license. Redistribution without substantial changes to the codebase or functionality is prohibited.

This amendment is made in accordance with the OSL 3.0's Section 16, which allows for modification of the license as long as the modified version is not presented as the original OSL. The modifications applied here are clearly delineated and include only the added condition of requiring substantial changes to redistributed code.
</details>

> [!WARNING]
> When sideloading with an ADP account cert, some functionality will break. If you value these features, sideload with a local development certificate instead. There is a workaround available that fixes one of the issues. See below for details.

<details>
<summary>Issues & Workaround</summary>
<br/>
To resolve the fixable issue, you need to match the app's bundle ID with your provisioning profile's App ID (excluding the team ID prefix):
<table>
<tr>
    <th>Issue</th>
    <th>Fixable</th>
    <th>Example</th>
</tr>
<tr>
    <td>Cannot change app icons</td>
    <td>✓</td>
    <td rowspan="5"><img src="https://adriancastro.dev/e0hbonxknepw.jpg" width="300"></td>
</tr>
<tr>
    <td>Cannot share items to Discord</td>
    <td>✗</td>
</tr>
<tr>
    <td>Cannot use passkeys</td>
    <td>✗</td>
</tr>
</table>

## Doing this will break notifications if the app is backgrounded or closed

</details>

## Installation

Builds can be found in the [Releases](https://github.com/pyoncord/BunnyTweak/releases/latest) tab.

> [!NOTE]
> Decrypted IPAs are sourced from the [Enmity](https://github.com/enmity-mod/) community. These are also used throughout Enmity related projects such as [enmity-mod/tweak](https://github.com/enmity-mod/tweak/) and [acquitelol/rosiecord](https://github.com/acquitelol/rosiecord).\
> All credits are attributed to the owner(s).

### Jailbroken

- Add the apt repo to your package manager: <https://repo.adriancastro.dev>
- Manually install by downloading the Debian package (or by building your own, see [Building](#building)) and adding it to your package manager

### Jailed

<a href="https://tinyurl.com/bdfkbtf7"><img src="https://adriancastro.dev/0byxzkzdsauj.png" width="230"></a>
<a href="https://tinyurl.com/24zjszuf"><img src="https://i.imgur.com/dsbDLK9.png" width="230"></a>
<a href="https://tinyurl.com/yh455zk6"><img src="https://i.imgur.com/46qhEAv.png" width="230"></a>

> [!NOTE]
> TrollStore may display an encryption warning, which you can disregard.

- Download and install [Bunny.ipa](https://github.com/pyoncord/BunnyTweak/releases/latest/download/Bunny.ipa) using your preferred sideloading method.

## Building

<details>
<summary>Instructions</summary>

> These steps assume you use macOS.

1. Install Xcode from the App Store. If you've previously installed the `Command Line Utilities` package, you will need to run `sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer` to make sure you're using the Xcode tools instead.

> If you want to revert the `xcode-select` change, run `sudo xcode-select -switch /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk`

2. Install the required dependencies. You can do this by running `brew install make ldid` in your terminal. If you do not have brew installed, follow the instructions [here](https://brew.sh/).

3. Setup your gnu make path:

```bash
export PATH="$(brew --prefix make)/libexec/gnubin:$PATH"
```

4. Setup [theos](https://theos.dev/docs/installation-macos) by running the script provided by theos.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"
```

If you've already installed theos, you can run `$THEOS/bin/update-theos` to make sure it's up to date.

5. Clone this repository via `git clone git@github.com:pyoncord/BunnyTweak.git` and `cd` into it.

6. To build, you can run `make package`.

The resulting `.deb` file will be in the `packages` folder.

</details>

## Contributors

[![Contributors](https://contrib.rocks/image?repo=bunny-mod/BunnyTweak)](https://github.com/bunny-mod/BunnyTweak/graphs/contributors)

<!-- @vladdy was here, battling all these steps so you don't have to. Have fun! :3 -->
<!-- @castdrian also was here simplifying these steps immensely -->

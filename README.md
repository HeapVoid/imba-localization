
# 🌐 JSON Localization for Imba

A lightweight Imba module for loading and handling JSON-based localization files in web applications. This utility fetches a localization file, selects the appropriate language based on the user's browser settings (or falls back to a default), and allows you to easily access localized strings throughout your application. Package includes helpful components for language selection and localization management.

## ✨ Features

- 🔍 **Automatic language detection** - Uses the user's browser language settings
- 💾 **Persistence**: Stores user choice in local storage across sessions
- 🔄 **Smart fallback system** - Falls back to a default language when needed
- 📦 **Optional split loading** - Loads only the selected language file and caches languages on demand
- 🧠 **Intuitive access** - Proxy-based access to translation strings
- 📡 **Event handling** - Support for `onready`, `onchange`, and `onerror` events
- 🧾 **Type declarations** - Includes package-level TypeScript declarations for editor and language-server imports
- 🚀 **Simple integration** - Easy to use in any Imba-based web application
- 🧩 **`<language-selector>`** - Plug and play tag component for switching languages

## 📘 Notes

- Language detection uses the first two characters from `navigator.language` (e.g., `en` from `en-US`)
- If the preferred language isn't available in your JSON file, it falls back to the default language
- Returns an empty string for missing translation keys instead of throwing errors


## 📦 Installation

```bash
# NodeJs
npm install imba-localization
# or Bun
bun add imba-localization
```

For local module development:

```bash
bun install
bun run test
```

## 🚀 Quick Start

### 1️⃣ Preload the localization file

Add this to your HTML head to load the localization file simultaneously with your application:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <!-- Other head elements -->
    <link rel="preload" href="path/to/lang.json" as="fetch" type="application/json" crossorigin="anonymous"/>
  </head>
  <body>
    <!-- Your app -->
  </body>
</html>
```

> 💡 **Tip:** You can host your localization file on GitHub Pages or any static hosting service, making it easy to update translations without redeploying your application.

### 2️⃣ Initialize in your Imba app

```imba
# app.imba
import { Localization } from 'imba-localization'

# Create an instance with the JSON URL and optional default language
const loc = new Localization("path/to/lang.json", "en")

# Set up event handlers
loc.onready = do
  console.log "Localization loaded!"
  
  # Access translations in various ways:
  console.log loc.hello               # Using dot notation
  console.log loc['goodbye']          # Using bracket notation
  console.log loc['user']['profile']  # Accessing nested properties

loc.onerror = do(error, details)
  # The Localization object can return following types of errors:
  # 'localization-no-file' - if there was a problem downloading a JSON file
  # 'localization-no-default' - if there is no default localization
  # 'localization-no-key' - if a requested interface key is missing
  console.error "Localization error:", error, details

loc.onchange = do(lang_key)
  console.log "Language changed to:", lang_key

# Get the current localization code
console.log loc.active

# Switch the active language
loc.active = "fr"  # Changes to French if available

# Loop through all the localizations
for key, data of loc.languages
  console.log key, data

# Get all the keys for the active language
console.log loc.languages[loc.active]

```

## 📄 Bundle JSON Structure

The original single-file format remains supported and is the default mode:

Your localization file should follow this format:

```json
{
  "en": {
    "welcome": "Welcome",
    "goodbye": "Goodbye",
    "user": {
      "profile": "Profile",
      "settings": "Settings"
    }
  },
  "fr": {
    "welcome": "Bienvenue",
    "goodbye": "Au revoir",
    "user": {
      "profile": "Profil",
      "settings": "Paramètres"
    }
  }
}
```

## 📦 Split Language Files

Split mode loads a small manifest first and then downloads only the selected language. Previously loaded languages are kept in memory and are not requested again.

```imba
const loc = new Localization('/localization/languages.json', 'en', {split: true})

# Optional when application startup needs to wait explicitly.
await loc.pending

# Assignment still works and starts an asynchronous language switch.
loc.active = 'fr'

# Use `use` when the caller needs to wait for the new dictionary.
await loc.use('fr')
```

Recommended file structure:

```text
public/localization/
├── languages.json
├── en.json
├── fr.json
└── ru.json
```

`languages.json` contains only language metadata and file locations:

```json
{
  "default": "en",
  "languages": {
    "en": { "name": "English", "flag": "us", "src": "en.json" },
    "fr": { "name": "Français", "flag": "fr", "src": "fr.json" },
    "ru": { "name": "Русский", "flag": "ru", "src": "ru.json" }
  }
}
```

Each language file contains the dictionary directly:

```json
{
  "welcome": "Welcome",
  "goodbye": "Goodbye",
  "user": {
    "profile": "Profile",
    "settings": "Settings"
  }
}
```

If `src` is omitted, the language code is used as the filename (`ru` → `ru.json`). The manifest `default` overrides the constructor fallback when present. A failed switch keeps the current language active and reports `localization-no-file` through `onerror`.

## 🛠️ API Reference

### Constructor

```imba
new Localization(url, default = 'en', options = {})
```

- `url`: Path to your JSON localization file
- `default`: Fallback language code (defaults to 'en')
- `options.split`: Treat `url` as a language manifest and load dictionaries on demand

### Properties

- `active`: Get or set the code of the active language
- `languages`: Available languages; unloaded split entries contain only `$` metadata
- `preferred`: Detected browser language (first 2 characters of `navigator.language`)
- `loaded`: Map of language codes whose dictionaries are already in memory
- `pending`: Promise settled after initial localization loading finishes

### Methods

- `lookup(path, fallback = '')`: Reads a nested value by dot path or path array
- `text(path, fallback = '', data = null)`: Reads a localized string and replaces `{key}` placeholders from `data`
- `table(path)`: Reads a nested object table, returning `{}` when missing
- `render(value, data = null)`: Replaces `{key}` placeholders in any string-like value
- `use(language)`: Loads and activates a language, returning a Promise
- `load(language)`: Loads a split dictionary without activating it

### Events

- `onready`: Called when localization data is successfully loaded
- `onerror`: Called when an error occurs (`error`, `details`)
- `onchange`: Called when the active language changes (`lang_key`)

## 🧩 Components

### LocalizationSelector

A customizable dropdown component that allows users to select from available in the JSON localization file languages.

```imba
import { Localization } from 'imba-localization'
const loc = new Localization("path/to/lang.json", "en")

# after importing Localization object 
# <language-selector> tag will be available 
# in any of you project your UI component
tag AppHeader
    <self>
      <language-selector state=loc> # state attribute is mandatory
```

To make this component work as intended, your JSON file will need some adjustments. For each supported language you will need to define the display name for the language and also the country code for the flag to show (for example `en` language is used in `gb` and `us` countries):

```json
"en": {
        "$": {
            "name": "English",
            "flag": "us"
        }
}
```

#### Visual Customization

Here are CSS classes (and one variable) you can redefine:
```imba
css
  $ease: 0.5s
  .main 
      cursor:pointer
      rd:8px px:15px py:8px 
      bgc:light-dark(#000000/10, #FFFFFF/20) 
      fw:500 fs:13px 
      ead:$ease
      bd:1px solid transparent
  .main-active 
      bgc:light-dark(#000000/20, #FFFFFF/30)
      bd:1px solid transparent
  .main-flag 
      mr:10px rd:50% w:20px h:20px
      bd:1px solid transparent
  .main-name 
      mr:10px
      bd:1px solid transparent
  .main-arrow 
      w:16px h:16px ml:auto
      fill:light-dark(#000000,#FFFFFF) 
      bd:1px solid transparent
      transition: transform $ease ease
      scale-y:-1
  .main-arrow-active
      bd:1px solid transparent
      scale-y:1
  .menu 
      t:100% l:50% x:-50% mt:2px rd:8px rd:8px py:5px zi:999
      fw:500 fs:13px
      backdrop-filter:blur(20px) 
      bd:1px solid transparent
      bgc:light-dark(#000000/5, #FFFFFF/10) 
      ead:$ease
  .menu-item 
      cursor:pointer
      bd:1px solid transparent
      d:hflex px:10px py:5px rd:8px m:5px
      bg@hover:light-dark(#000000/10, #FFFFFF/20)
  .menu-item-icon 
      bd:1px solid transparent
      h:20px w:20px mr:10px rd:50%
  .menu-item-text 
      fs:13px
```
`<language-selector>` can be easily customized through CSS and Imba tag (class) inheritance. Here how the above classes can be adjusted via the inheritance, or through CSS selectors:

```imba

import { Localization } from 'imba-localization'
const loc = new Localization("path/to/lang.json", "en")

# --------------------
# Inheritance
# --------------------

# Create an inheritent class
tag custom-languages < language-selector
  css
    $ease: 1s
    .menu-item rd:2px
    .menu-item-icon h:30px w:30px

# Using the adjusted component
tag MyApp
    <self>
      <custom-languages state=loc>


# --------------------
# CSS selectors
# --------------------

global css
  language-selector
    @not(#_) # is needed for higher precedence
      .main
        bgc: #992033
        bc: #992033
      .main-active
        bgc: blue2
        bc: #992033
      .menu
        bgc: #992033
        bc: #992033
      .menu-item
        bgc@hover: orange4
        c@hover: black

# Using component that will be restyled
tag MyApp
    <self>
      <language-selector state=loc>

```

#### Flag collections

You can redefine the collection of flag icons through the `icons` attribute:

```imba
<language-selector icons='https://flagicons.lipis.dev/flags/4x3/##.svg'>
```
There are many flag collections out there:
- https://kapowaz.github.io/square-flags/flags/##.svg (default one)
- https://hatscripts.github.io/circle-flags/flags/##.svg
- https://flagcdn.com/##.svg
- https://cdn.simplelocalize.io/public/v1/flags/##.svg
- https://cdn.jsdelivr.net/gh/hampusborgos/country-flags@main/svg/##.svg
- https://flagicons.lipis.dev/flags/4x3/##.svg

You can use any other collection you prefer, just change the actual country code to `##` in the url, so the component could replace it with the actual code to obtain a flag for a needed country. 

#### Dropdown arrow customization

You can use any arrow icon you prefer (or remove it though CSS) by passing a tag of the image to the LanguageSelector `arrow` attribute:

```imba
const arrow = <path d="...">

<language-selector arrow=arrow>
```

### ArrowIcon

The default arrow icon used in the LocalizationSelector component is available as a separate icon (in case for some reason you don't want to use [imba-phosphor-icons](https://www.npmjs.com/package/imba-phosphor-icons) package by Sindre).

```imba
import {path-arrow-down} from 'imba-localization'

tag App
	<self>
    <svg viewBox="0 0 256 256">
      css w:20px h:20px stroke:red
		  <{svg-arrow-down}>
			
```

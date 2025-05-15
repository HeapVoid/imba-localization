
# 🌐 JSON Localization for Imba

A lightweight Imba module for loading and handling JSON-based localization files in web applications. This utility fetches a localization file, selects the appropriate language based on the user's browser settings (or falls back to a default), and allows you to easily access localized strings throughout your application. Package includes helpful components for language selection and localization management.

## ✨ Features

- 🔍 **Automatic language detection** - Uses the user's browser language settings
- 💾 **Persistence**: Stores user choice in local storage across sessions
- 🔄 **Smart fallback system** - Falls back to a default language when needed
- 🧠 **Intuitive access** - Proxy-based access to translation strings
- 📡 **Event handling** - Support for `onready`, `onchange`, and `onerror` events
- 🚀 **Simple integration** - Easy to use in any Imba-based web application
- 🧩 **`<LocalizationSelector>`** - Plug and play component for switching languages

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
import { LocalizationState } from 'imba-localization'

# Create an instance with the JSON URL and optional default language
const loc = new LocalizationState("path/to/lang.json", "en")

# Set up event handlers
loc.onready = do
  console.log "Localization loaded!"
  
  # Access translations in various ways:
  console.log loc.hello               # Using dot notation
  console.log loc['goodbye']          # Using bracket notation
  console.log loc['user']['profile']  # Accessing nested properties

loc.onerror = do(error, details)
  # The LocalizationState object can return following types of errors:
  # 'no_localization_file' - if there were a problem when downloading JSON file
  # 'no_default_localization' - if there is no localization in the file for the default language
  # 'no_localization_key' - if there is no requiered (from the interface) key in the file
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

## 📄 JSON Structure

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

## 🛠️ API Reference

### Constructor

```imba
new LocalizationState(url, default = 'en')
```

- `url`: Path to your JSON localization file
- `default`: Fallback language code (defaults to 'en')

### Properties

- `active`: Get or set the code of the active language
- `languages`: Object containing all loaded language data
- `preferred`: Detected browser language (first 2 characters of `navigator.language`)

### Events

- `onready`: Called when localization data is successfully loaded
- `onerror`: Called when an error occurs (`error`, `details`)
- `onchange`: Called when the active language changes (`lang_key`)

## 🧩 Components

### LocalizationSelector

A customizable dropdown component that allows users to select from available in the JSON localization file languages.

```imba
import { LocalizationState, LocalizationSelector } from 'imba-localization'
const loc = new LocalizationState("path/to/lang.json", "en")

# In your UI component
tag AppHeader
    <self>
      <LocalizationSelector state=loc> # state attribute is mandatory
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
  .main-active 
      bgc:light-dark(#000000/20, #FFFFFF/30)
  .main-flag 
      mr:10px rd:50% w:20px h:20px
  .main-name 
      mr:10px
  .main-arrow 
      w:16px h:16px ml:auto
      fill:light-dark(#000000,#FFFFFF) 
      scale-y:-1 
      ead:$ease
  .menu 
      t:100% l:50% x:-50% mt:2px rd:8px rd:8px py:5px zi:999
      fw:500 fs:13px
      backdrop-filter:blur(20px) 
      bgc:light-dark(#000000/5, #FFFFFF/10) 
      ead:$ease
  .menu-item 
      cursor:pointer
      d:hflex px:10px py:5px rd:8px m:5px
      bg@hover:light-dark(#000000/10, #FFFFFF/20)
  .menu-item-icon 
      h:20px w:20px mr:10px rd:50%
  .menu-item-text 
      fs:13px
```
LanguageSelector can be easily customized through CSS and Imba tag (class) inheritance. Here how the above classes can be adjusted via the inheritance:

```imba
import { LocalizationState, LocalizationSelector } from 'imba-localization'
const loc = new LocalizationState("path/to/lang.json", "en")

# Create an inheritent class
tag Languages < LocalizationSelector
  css
    $ease: 1s
    .menu-item rd:2px
    .menu-item-icon h:30px w:30px

# Using the adjusted component
tag MyApp
    <self>
      <Languages state=loc>
```

#### Flag collections

You can redefine the collection of flag icons through the `icons` attribute:

```imba
<LocalizationSelector icons='https://flagicons.lipis.dev/flags/4x3/##.svg'>
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
tag SomeIcon
	<self>
		<svg viewBox="..." xmlns="http://www.w3.org/2000/svg">
			<path d="...">


<LocalizationSelector arrow=SomeIcon>
```

### ArrowIcon

The default arrow icon used in the LocalizationSelector component is available as a separate icon (in case for some reason you don't want to use [imba-phosphor-icons](https://www.npmjs.com/package/imba-phosphor-icons) package by Sindre).

```imba
import {ArrowIcon} from 'imba-localization'

tag App
	<self>
		<ArrowIcon>
			css w:20px h:20px stroke:red
```
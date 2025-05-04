
# JSON Localization for Imba

A lightweight Imba module for loading and handling JSON-based localization files in web applications. This utility fetches a localization file, selects the appropriate language based on the user's browser settings (or falls back to a default), and allows you to easily access localized strings throughout your application.

## ✨ Features

- Automatically detects the user's preferred language
- Falls back to a default language if needed
- Proxy-based access to translation strings
- Supports `onready`, `onchange` and `onerror` events
- Simple to use in any Imba-based web application

## 📦 Installation

Just include the module in your project or copy the class directly into your codebase.
```bash
npm install imba-localization-loader
```

## 🚀 Usage

First of all, preload the localization file in HTML head, so it is loaded simultaniously with the application itself:
```html
<!DOCTYPE html>
<html lang="en">
	<head>
    ...
		<link rel="preload" href="ADDRESS_TO_JSON" as="fetch" type="application/json" crossorigin="anonymous"/>
    ...
	</head>
	<body>
	</body>
</html>
```
Such localization file can be placed on any static hosting. In my experience Github Pages works perfectly for that purpose. Moreover, it also allows to update localization by just pushing updated file to the repository.

Here’s an example of how to use it in an Imba app:

```imba
# app.imba

import Localization from 'imba-localization-loader'

# To create an instance pass the address to the JSON and (optionally) default language
const loc = new Localization("ADDRESS_TO_JSON", "en")

loc.onready = do
	console.log loc['hello']      # Output: "Hello" (or translated value)
	console.log loc['goodbye']    # Output: "Goodbye" (or translated value)

loc.onerror = do(msg, err)
	console.error "Localization load error:", msg, err

loc.change = do(language)
	console.error "Language changed:", language

# Later in your app, you can switch the language:
loc.active = "fr"   # Sets the active language to French (if available)

# The language file can be structured and accessed as usual:
console.log loc['forms']['login']['buttons']['enter']

```

## 📄 JSON File Format

The localization file (`/lang.json`) should look like this:

```json
{
  "en": {
    "hello": "Hello",
    "goodbye": "Goodbye"
  },
  "fr": {
    "hello": "Bonjour",
    "goodbye": "Au revoir"
  }
}
```

## 📘 Notes

- The module attempts to detect the language from `window.navigator.language`, using the first two characters (e.g., `en` from `en-US`).
- If the preferred language isn't available, it uses `'en'` by default.

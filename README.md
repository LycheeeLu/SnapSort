
# Snapsort

Snapsort is an ios App that access your screenshots in your album (under user consent) and automatically sort them based on themes from the extracted text.

## 📦 Installation

### Requirements

- macOS with Xcode (version >= 14.0)
- iOS Simulator (comes with Xcode)
- run the app on a real device or simulator

### 🧪 _Run in Simulator (No Signing Required)_

1. Clone the repository:

```bash
git clone https://github.com/LycheeeLu/SnapSort.git
cd SnapSor
```

2. Open the Xcode project:

```bash
open SnapSort.xcodeproj
```
3. In Xcode:

- Select a Simulator (e.g. iPhone 15 Pro) from the device list near the top.

- Do not choose “Any iOS Device (arm64)”, or you will get a code signing error.

- Go to Signing & Capabilities → Uncheck “Automatically manage signing”.

- Set Team to “None” if prompted.





## 🛠 Built With

- **Swift**   
- **Xcode** 
- **Swift UI and SwiftData**  
- **Machine Learning & Apple's Vision Framework (optical character recognition (OCR))** 
- **Local Storage** 


## 🖼 Feature
 
- Provides default themes (e.g., Travel, Notes, Code, Shopping, Work) to categorize your screenshots

- Browse, edit theme/topic keywords, and customize color tags to define how you want your screenshots to be sorted
- Designed to be lightweight and fast


## 🪄 Usage

### _1. Give permission to access photo library_
### _2. Click categorization button_
<div align="center">
  <img src="images/access-allow-1.png" alt="Step 1" width="150"/>
  <img src="images/access-allow-2.png" alt="Step 2" width="150"/>
  <img src="images/access-allow-3.png" alt="Step 3" width="150"/>
  <img src="images/access-allow-4.png" alt="Step 4" width="150"/>
</div>

### _3. View full or theme-based sorted snaps gallery_
<div align="center">
  <img src="images/gallery-1.png" alt="Gallery 1" width="160"/>
  <img src="images/gallery-2.png" alt="Gallery 2" width="160"/>
  <img src="images/gallery-3.png" alt="Gallery 3" width="160"/>
</div>

### _4. Edit existing Themes with more topic keywords_
### _5. Or add more Themes of intersts_
<div align="center">
  <img src="images/theme-edit-1.png" alt="Theme Edit 1" width="160"/>
  <img src="images/theme-edit-2.png" alt="Theme Edit 2" width="160"/>
  <img src="images/theme-edit-3.png" alt="Theme Edit 3" width="160"/>
</div>


# **🛡️ TITANIUM \- Ultimate BABFT Image Loader**

**Titanium** is the most powerful and optimized Image Loader script (converts images to blocks) for *Build A Boat For Treasure* on Roblox. The latest version brings absolute network stability and an enhanced user experience.

## **📥 Installation (Script Loader)**

Copy the code below and paste it into your Executor (Krnl, Fluxus, Delta, etc.):
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/HairBaconGamming/BABFT-Image-Loader-Free/refs/heads/main/Main.lua"))()
```

## **🔥 Key Features (v7.3.0)**

### **🚀 Performance & Network**

* **Smart Throttle (New):** The system automatically adjusts packet sending speed based on real-time Ping. This completely prevents Ping spikes (100k+) and disconnections when building large structures.  
* **RAM Optimized:** Smart RAM optimization mode allows building large images on low-end devices without crashing.  
* **Real-time Stats:** Live FPS/RAM graphs and Estimated Time of Arrival (ETA) calculation based on actual building speed (Blocks/second).

### **🔐 Security System (HairKey Enterprise v2.1)**

* **Auto-Save & Auto-Login:** Automatically saves the Key after successful verification. Subsequent logins are automatic; no need to re-enter the Key.  
* **Server Wake-up Protocol:** Automatically detects and waits for the key server (Render) to "wake up" if it's sleeping, instead of immediately reporting a connection error.  
* **Handshake Secure:** Protects user HWID through a new secure handshake mechanism.

### **🎨 Image Processing & Building**

* **DeepCopy Logic (Fix):** Fixed an issue where resizing or locking the aspect ratio failed when RAM optimization was enabled. You can now freely adjust image dimensions without losing original data.  
* **Advanced Transformations:**  
  * **3D Voxel Mode:** Generates depth (thickness) for the image based on pixel brightness.  
  * **Bending:** Bends the image into an arc shape.  
  * **Tilting:** Tilts the image along the X/Y axes.  
* **Dithering & Chroma Key:** Supports color dithering and automatic background removal (green/white screen removal).

## **📖 User Guide**

1. **Get Key:**  
   * On the first launch, click **"GET KEY"** to copy the link.  
   * Complete the short link steps to get your Key.  
   * Paste the Key into the box and click **"VERIFY"**. (The Key will be auto-saved for next time).  
2. **Load Image:**  
   * Paste the image link (Direct URL, ending in .png/.jpg) into the **Image Link** box.  
   * Click **Load**.  
3. **Configuration:**  
   * Adjust dimensions (Width/Height) and click **Apply Resize**.  
   * Go to the **Settings** tab to tweak parameters like Scale, Delay, and Threads.  
4. **Building:**  
   * Click **Preview** to see the position. Press F to toggle Gizmo modes (Move/Rotate).  
   * Click **BUILD** to start construction.

## **🛠️ System Requirements**

* **Game:** Build A Boat For Treasure.  
* **Executor:** Supports most modern executors (Script-Ware, Fluxus, Hydrogen, Delta, Arceus X, etc.).  
* **In-Game Tools:** Requires the **Scaling Tool** for optimal performance. The **Trowel Tool** and **Painting Tool** are also highly recommended.

## **⚠️ Notes**

* Do not spam the Build button.  
* If Ping becomes too high (\>500ms), the script will automatically pause to drain the network queue. Please be patient.  
* Use a VIP server to avoid being disturbed by other players while building.

Developed by HairBaconGamming & Associates.  
Enjoy Titanium and build amazing structures\!

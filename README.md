# **🚤 Titanium Loader \- BABFT Image Builder**

**Titanium Loader** is a state-of-the-art Lua script designed for *Build A Boat For Treasure* (Roblox). It utilizes advanced algorithms like **Greedy Meshing** and **Blind Pipelining** to render images into the game with maximum speed, efficiency, and precision.

## **✨ Key Features (v5.9.22)**

### **🚀 Performance & Algorithms**

* **Blind Pipelining (Fire & Forget):** Decouples the building process from network replication, allowing the script to place blocks as fast as your connection permits (\~300% faster than traditional loaders).  
* **Greedy Meshing Compression:** analyzing the image in 2D to merge identical pixels into large rectangular blocks, significantly reducing block count and lag.  
* **Spatial Hashing V2:** Uses advanced 3D chunking for instant block detection (O(1) complexity), eliminating the lag caused by scanning thousands of parts.

### **🛠️ Intelligent Build Process (4-Phase System)**

1. **Build & Scale:** Rapidly places and scales blocks to define the structure.  
2. **Batch Painting:** Applies colors in massive bulk requests to optimize network usage.  
3. **Deep Verification:** Iteratively scans the workspace to detect and repair missing or misscaled blocks.  
4. **Cleanup Protocol:** Automatically detects and removes excess/duplicate blocks using the Delete Tool to ensure a clean result.

### **🎮 User Experience**

* **3D Image Projection:** Previews the actual image on a transparent part in the 3D world, not just a colored box.  
* **Smart Drag:** Simply hold click on the preview to drag it around naturally.  
* **Real-time Stats:** View estimated cost, time remaining, building speed (b/s), and physical world dimensions live.  
* **Config System:** Automatically saves and loads your settings (TitaniumLoader/config.json).

## **📋 Requirements**

To use Titanium Loader effectively, you need the following items in your **Roblox Inventory**:

1. **Building Tool** (Hammer)  
2. **Scaling Tool** (Tape Measure)  
3. **Painting Tool** (Paintbrush)  
4. **Delete Tool** (Trowel) \- *Required for Cleanup Phase*  
5. **Plastic Blocks** (Ideally a lot\!)

## **📖 How To Use**

1. **Execute the Script:** Copy the Main.lua content and run it in your executor (Synapse X, Krnl, etc.).  
2. **Load Image:**  
   * Paste a direct image link (ending in .png or .jpg) into the input box.  
   * Click **Load**.  
3. **Adjust & Preview:**  
   * Use the **W** (Width) and **H** (Height) inputs to resize.  
   * Toggle **Lock Ratio** to maintain aspect ratio.  
   * Click **Preview** to see the hologram.  
   * **Move:** Drag the preview with your mouse or use the Gizmo handles.  
   * **Rotate:** Press **F** to switch Gizmo to Rotate mode.  
4. **Configure:**  
   * Go to the **Settings** tab.  
   * Adjust **Scale** (Pixel size) and **Thickness** (Block depth).  
   * Set **Compress Level** (Higher \= Less blocks, less detail).  
5. **Build:**  
   * Click **BUILD** and wait for the magic to happen\!  
   * *Do not move your character too far while building.*

## **⚙️ Configuration Guide**

| Setting | Description | Recommended |
| :---- | :---- | :---- |
| **Parallel Threads** | Number of concurrent build workers. Higher is faster but requires better internet. | 3 \- 5 |
| **Compress Level** | Tolerance for color merging. Higher values merge more colors, saving blocks. | 10 \- 30 |
| **Scale** | The size of each "pixel" in studs (X/Y axis). | 1.0 |
| **Thickness (Z)** | The depth/thickness of the generated wall in studs. | 0.5 \- 1.0 |
| **Batch Size** | How many actions to buffer before sending to the server. | 50 \- 100 |
| **Batch Waits** | Throttling limits for Paint/Build/Scale actions to prevent disconnections. | Default |

## **⚠️ Troubleshooting**

* **"Missing Blocks"**: The script has a built-in *Ultimate Repair* phase. Just wait; it will retry building missing parts automatically up to 5 times.  
* **"Ghost Blocks"**: If you see blocks that are unpainted or unscaled, the *Cleanup Protocol* will likely remove or fix them at the end.  
* **Disconnection**: Lower the **Parallel Threads** and increase the **Delay**.

**Credits:**

* Developed by *HairBaconGamming*  
* Titanium Core v5.9.22

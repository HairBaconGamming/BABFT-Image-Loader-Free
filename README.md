# Titanium Loader - BABFT Image Builder (v5.5.2)

**Titanium Loader** is a powerful Lua script for the game *Build A Boat For Treasure* on Roblox, allowing you to automatically build images (pixel art) from the internet into the game quickly and accurately.

### ✨ Key Features

**🖼️ Smart Image Loading:**
*   Supports loading images directly from URL paths (only .PNG, .JPG, .JPEG).

**📏 Resize System:**
*   Customize the image **Width** and **Height**.
*   **Lock Ratio** mode ensures the aspect ratio is maintained when resizing.
*   Uses the **Nearest Neighbor** algorithm to keep pixels sharp.

**🚀 Parallel Building:**
*   Supports running **1 to 20 parallel threads** to increase building speed multiple times over.

**📊 Smart Stats (Real-time):**
*   **Available:** Displays the actual amount of Plastic Blocks in your inventory (updates every 0.5s).
*   **Estimated Cost:** Automatically calculates the precise number of blocks needed based on compression and image size.

**🛠️ Smart Repair:**
*   Automatically detects and rebuilds missing blocks.
*   Automatically checks and corrects the **Scale** of blocks that are distorted due to lag.

**🎮 Flexible Control:**
*   Visual **Preview** system with **Gizmo** (Move/Rotate) to align the position before building.
*   **Pause** and **Stop** buttons give you full control over the building process.

**💾 Optimization:**
*   **Compress Level:** Merges identical pixels into a larger single block to save blocks and reduce lag.

---

### 📖 User Guide

1.  **Launch Script:** Copy and paste the source code into your Executor and run it.
2.  **Load Image:**
    *   Paste the image link (Direct link, ending in .png/.jpg) into the **Image Link** box.
    *   Press **Load**.
3.  **Resize (Optional):**
    *   Enter the desired size in the **W** (Width) or **H** (Height) box.
    *   Enable **Lock Ratio** if you want to keep the proportions.
    *   Press **Apply Resize**.
4.  **Preview:**
    *   Press **Preview** to show the image frame in-game.
    *   Use the mouse to drag the arrows (**Gizmo**) to move or rotate the image.
    *   Press **F** to switch between **Move** and **Rotate** modes.
    *   Press **X** to cancel Preview.
5.  **Config & Build:**
    *   Go to the **Settings** tab to adjust Scale, Parallel Threads, and Compress Level.
    *   Check the **Estimated Cost** to ensure you have enough blocks.
    *   Press **BUILD** to start.

---

### ⚙️ Settings Explanation

*   **Parallel Threads (1-20):** The number of threads running simultaneously. Higher = Faster building but may cause lag or disconnection if your network is weak. **Recommended: 2-5.**
*   **Compress Level (0-50):** The level of color merging.
    *   *Low (0-5):* Detailed colors, consumes many blocks.
    *   *High (10-50):* Saves blocks, colors are less detailed.
*   **Scale (0.05 - 2.0):** The size of each "pixel" in the game. Default is **1.0** (equivalent to 1 small block).
*   **Delay:** The wait time between block placements. Decrease this to build faster if your ping is low.
*   **Batch Size:** The number of blocks processed in a single Request.

---

### ⚠️ Notes

> *   You must have the **Building Tool**, **Painting Tool**, and **Scaling Tool** equipped in your inventory for the script to function fully.
> *   Ensure you are inside your team's **Zone**.
> *   If you get disconnected, decrease the **Parallel Threads**.

***Titanium Loader - Developed for BABFT Community***

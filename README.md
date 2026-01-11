# Outpost: Offline-First Race Timing System

**Outpost** is a professional-grade iOS application designed for timing remote trail races and Backyard Ultras. It utilizes a peer-to-peer mesh network to sync race data between checkpoints without requiring an internet connection.

<p align="center">
  <img src="assets/Simulator Screenshot - iPhone Air - 2026-01-10 at 03.08.38.png" width="200" />
  <img src="assets/Simulator Screenshot - iPhone Air - 2026-01-10 at 03.11.51.png" width="200" />
  <img src="assets/Simulator Screenshot - iPhone Air - 2026-01-10 at 03.19.07.png" width="200" />
</p>

##  Key Features

* **Mesh Networking (Offline Sync):** Built on `MultipeerConnectivity`, allowing devices to automatically sync runner history and race state when in proximity, with zero internet or cloud dependence.
* **Automatic Backfill:** "Self-healing" sync engine that detects when a peer reconnects after being offline and automatically transmits missing historical data.
* **Backyard Ultra Engine:** specialized dashboard for the "Last One Standing" format, featuring automated "Reaper" logic to eliminate runners who fail to complete a lap within the hour.
* **SwiftData & Core Data:** Complex relational schema (`Race` → `Checkpoints` → `Runners` → `Events`) optimized for high-frequency reads/writes.
* **Data Export:** Generates CSV reports compatible with Excel/Numbers for race directors.
* **Safety Monitoring:** Tracks runner pace between checkpoints to alert race staff of overdue or missing athletes.

##  Tech Stack

* **Language:** Swift 6
* **UI Framework:** SwiftUI
* **Persistence:** SwiftData (Schema Migration & Relationship Management)
* **Networking:** MultipeerConnectivity (Advertiser/Browser pattern)
* **Architecture:** MVVM with Dependency Injection (`AppDependencies` container)
* **Concurrency:** Swift Concurrency (`async/await`, `Task`, `@MainActor`)

##  Engineering Highlights

### The "Backfill" Sync Engine
One of the biggest challenges was ensuring data consistency in intermittent network conditions. I implemented a custom handshake protocol:
1.  Device A connects to Device B.
2.  `SyncManager` detects the connection and queries the local store.
3.  Missing events are batched and broadcasted.
4.  Receiving devices perform idempotency checks (deduplication) before inserting into `SwiftData`.

### Backyard Ultra Logic
The app manages the complex state of a Backyard Ultra using a custom `BackyardLogic` engine that is decoupled from the UI. It calculates:
* Current Yard (Lap) based on elapsed time.
* Countdown to the next bell.
* Automatic DNF status for runners who fail to check in before the hour transition.


---
*Created by [Leonardo Solis] - 2026*

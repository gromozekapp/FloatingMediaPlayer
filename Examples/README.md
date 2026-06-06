# Examples

## FMP_EXAMPLE (iOS)

1. Open `FMP_EXAMPLE/FMP_EXAMPLE.xcodeproj` in Xcode.
2. Select an iOS Simulator or device.
3. Build and run (⌘R).

The project links to the local Swift package at the repository root (`../..` from this folder).

If Xcode shows **Missing package product 'FloatingMediaPlayer'**:

1. Close and reopen the project
2. **File → Packages → Reset Package Caches**
3. **File → Packages → Resolve Package Versions**
4. Or in Terminal:
   ```bash
   cd Examples/FMP_EXAMPLE
   xcodebuild -resolvePackageDependencies -project FMP_EXAMPLE.xcodeproj
   ```

### Tabs

| Tab | Description |
|-----|-------------|
| **Basic** | Pick a file or photo, show the floating player |
| **Custom** | Custom `FloatingPlayerConfiguration` + delegate |
| **Presets** | `.minimal`, `.compact`, `.full` presets |

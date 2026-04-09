//
//  UNPDemoScreenshotsPage.swift
//

import SwiftUI
import UniformTypeIdentifiers
import zlib

struct UNPDemoScreenshotsPage: View {
    @EnvironmentObject private var store: UNPDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var roleFilter: UNPDemoRoleFilter = .paid
    @State private var journeyFilter: UNPDemoJourney = .home
    @State private var showShare = false
    @State private var exportURL: URL?
    
    private var items: [UNPDemoScreenshotItem] {
        store.demoScreenshotCatalog().filter { item in
            item.roles.contains(roleFilter) && item.journey == journeyFilter
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(UNPDemoRoleFilter.allCases) { r in
                            filterChip(r.label, roleFilter == r) { roleFilter = r }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(UNPDemoJourney.allCases) { j in
                            filterChip(j.label, journeyFilter == j) { journeyFilter = j }
                        }
                    }
                    .padding(.horizontal)
                }
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                        ForEach(items) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(UNPColors.accent.opacity(0.25))
                                    .frame(height: 100)
                                    .overlay {
                                        Image(systemName: "photo")
                                            .font(.largeTitle)
                                            .foregroundStyle(UNPColors.accent)
                                    }
                                Text(item.title)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(UNPColors.cream)
                                    .lineLimit(2)
                            }
                            .padding(10)
                            .background(UNPColors.cardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: UNPRadius.small))
                        }
                    }
                    .padding(20)
                }
            }
            .background(UNPColors.background)
            .navigationTitle("Demo gallery")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Export ZIP") {
                        exportURL = writeExportZip()
                        showShare = exportURL != nil
                    }
                }
            }
            .sheet(isPresented: $showShare) {
                Group {
                    if let url = exportURL {
                        UNPShareSheet(items: [url])
                    } else {
                        Text("Could not create export.")
                            .foregroundStyle(UNPColors.cream)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(UNPColors.background)
                    }
                }
            }
        }
    }
    
    private func filterChip(_ title: String, _ on: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(on ? UNPColors.accent : UNPColors.cardSurface)
                .foregroundStyle(on ? UNPColors.background : UNPColors.cream)
                .clipShape(Capsule())
        }
    }
    
    private func writeExportZip() -> URL? {
        let catalog = store.demoScreenshotCatalog()
        let payload: [[String: Any]] = catalog.map {
            [
                "id": $0.id,
                "title": $0.title,
                "journey": $0.journey.rawValue,
                "roles": $0.roles.map(\.rawValue)
            ]
        }
        guard let json = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]) else { return nil }
        let readme = Data("""
        Until The Next Pour — demo export
        Generated: \(ISO8601DateFormatter().string(from: Date()))
        Contains manifest.json (screen catalog) and README.txt
        """.utf8)
        guard let zipData = UNPZipBuilder.build(files: [
            ("manifest.json", json),
            ("README.txt", readme)
        ]) else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("UNP_Demo_Export.zip")
        do {
            try zipData.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}

// MARK: - Minimal valid ZIP (store / uncompressed)

enum UNPZipBuilder {
    static func build(files: [(String, Data)]) -> Data? {
        guard !files.isEmpty else { return nil }
        var out = Data()
        var entries: [(crc: UInt32, size: UInt32, nameLen: UInt16, localOffset: UInt32)] = []
        
        for (name, data) in files {
            let localOffset = UInt32(out.count)
            let nameBytes = Data(name.utf8)
            let crc = computeCRC32(data)
            let sz = UInt32(data.count)
            let local = makeLocalFileHeader(crc: crc, comp: sz, uncomp: sz, nameLen: UInt16(nameBytes.count))
            out.append(local)
            out.append(nameBytes)
            out.append(data)
            entries.append((crc, sz, UInt16(nameBytes.count), localOffset))
        }
        
        let centralOffset = UInt32(out.count)
        var central = Data()
        for (i, pair) in files.enumerated() {
            let nameBytes = Data(pair.0.utf8)
            let e = entries[i]
            let h = makeCentralFileHeader(crc: e.crc, size: e.size, nameLen: e.nameLen, localOffset: e.localOffset)
            central.append(h)
            central.append(nameBytes)
        }
        let centralSize = UInt32(central.count)
        out.append(central)
        out.append(makeEndRecord(entryCount: UInt16(files.count), centralSize: centralSize, centralOffset: centralOffset))
        return out
    }
    
    private static func computeCRC32(_ data: Data) -> UInt32 {
        data.withUnsafeBytes { raw in
            guard let base = raw.bindMemory(to: UInt8.self).baseAddress else { return 0 }
            return UInt32(zlib.crc32(0, base, uInt(data.count)))
        }
    }
    
    /// 30 bytes + filename + file data
    private static func makeLocalFileHeader(crc: UInt32, comp: UInt32, uncomp: UInt32, nameLen: UInt16) -> Data {
        var d = Data()
        d.append(contentsOf: [0x50, 0x4b, 0x03, 0x04])
        d.append(u16le(20))
        d.append(u16le(0))
        d.append(u16le(0))
        d.append(u16le(0))
        d.append(u16le(0))
        d.append(u32le(crc))
        d.append(u32le(comp))
        d.append(u32le(uncomp))
        d.append(u16le(nameLen))
        d.append(u16le(0))
        return d
    }
    
    /// 46 bytes + filename
    private static func makeCentralFileHeader(crc: UInt32, size: UInt32, nameLen: UInt16, localOffset: UInt32) -> Data {
        var d = Data()
        d.append(contentsOf: [0x50, 0x4b, 0x01, 0x02])
        d.append(u16le(0x0314))
        d.append(u16le(20))
        d.append(u16le(0))
        d.append(u16le(0))
        d.append(u16le(0))
        d.append(u16le(0))
        d.append(u32le(crc))
        d.append(u32le(size))
        d.append(u32le(size))
        d.append(u16le(nameLen))
        d.append(u16le(0))
        d.append(u16le(0))
        d.append(u16le(0))
        d.append(u16le(0))
        d.append(u32le(0))
        d.append(u32le(localOffset))
        return d
    }
    
    private static func makeEndRecord(entryCount: UInt16, centralSize: UInt32, centralOffset: UInt32) -> Data {
        var d = Data()
        d.append(contentsOf: [0x50, 0x4b, 0x05, 0x06])
        d.append(u16le(0))
        d.append(u16le(0))
        d.append(u16le(entryCount))
        d.append(u16le(entryCount))
        d.append(u32le(centralSize))
        d.append(u32le(centralOffset))
        d.append(u16le(0))
        return d
    }
    
    private static func u16le(_ v: UInt16) -> Data {
        var l = v.littleEndian
        return Data(bytes: &l, count: 2)
    }
    
    private static func u32le(_ v: UInt32) -> Data {
        var l = v.littleEndian
        return Data(bytes: &l, count: 4)
    }
}

struct UNPShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview("UNP Demo gallery") {
    UNPDemoScreenshotsPage()
        .environmentObject(UNPDataStore.shared)
}

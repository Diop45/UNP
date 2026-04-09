import SwiftUI
import PhotosUI
import UIKit

struct CommunityView: View {
    @EnvironmentObject private var store: UNPDataStore
    @State private var selectedEvent: UNPEvent?
    @State private var showPourCircle = false
    @State private var selectedDay: Date = .now
    
    private var headerName: String {
        let trimmed = store.user.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Friend" : trimmed
    }
    
    private var calendarDays: [Date] {
        let base = Calendar.current.startOfDay(for: selectedDay)
        return (-2...4).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: base) }
    }
    
    private var dayEvents: [UNPEvent] {
        store.events
            .filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDay) }
            .sorted { $0.startTime < $1.startTime }
    }
    
    private var timelineEvents: [UNPEvent] {
        if dayEvents.count >= 4 { return dayEvents }
        let fallback = store.events.sorted { $0.startTime < $1.startTime }
        let combined = dayEvents + fallback.filter { !dayEvents.contains($0) }
        return Array(combined.prefix(4))
    }
    
    private var totalUnreadCount: Int {
        store.events.reduce(into: 0) { result, event in
            result += min(9, store.messages(for: event.id).count)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            daySelector
            ScrollView(.vertical, showsIndicators: false) {
                timelineSchedule
            }
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(item: $selectedEvent) { event in
            NavigationStack {
                CommunityEventRoomView(event: event)
            }
            .environmentObject(store)
        }
        .sheet(isPresented: $showPourCircle) {
            NavigationStack {
                UNPPourCircleView()
            }
            .environmentObject(store)
        }
        .onAppear {
            if let first = calendarDays.first {
                selectedDay = first
            } else {
                selectedDay = Calendar.current.startOfDay(for: .now)
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.black.opacity(0.7))
                Spacer()
                Circle()
                    .fill(UNPColors.creamMuted(0.25))
                    .frame(width: 34, height: 34)
                    .overlay(Text(String(headerName.prefix(1))).font(.subheadline.bold()))
            }
            .padding(.bottom, 2)
            
            Text("Today's tasks")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(.black)
            
            Text(formattedSelectedDay)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.black)
            
            Text("\(timelineEvents.count) tasks today · \(totalUnreadCount) messages")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
    }
    
    private var daySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(calendarDays, id: \.self) { day in
                    Button {
                        selectedDay = day
                    } label: {
                        VStack(spacing: 2) {
                            Text(dayNumber(day))
                                .font(.headline.weight(.semibold))
                            Text(dayLabel(day))
                                .font(.caption2)
                        }
                        .foregroundStyle(Calendar.current.isDate(day, inSameDayAs: selectedDay) ? Color.white : .black.opacity(0.65))
                        .frame(width: 54, height: 68)
                        .background(
                            Calendar.current.isDate(day, inSameDayAs: selectedDay)
                            ? UNPColors.tabBarSelected
                            : Color.black.opacity(0.06)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
    
    private var eventStories: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(dayEvents) { event in
                    Button {
                        selectedEvent = event
                    } label: {
                        VStack(spacing: 8) {
                            Circle()
                                .strokeBorder(Color.gray.opacity(0.35), lineWidth: 2)
                                .background(Circle().fill(Color.black.opacity(0.03)))
                                .frame(width: 58, height: 58)
                                .overlay(
                                    Text(event.name.prefix(1))
                                        .font(.headline.bold())
                                        .foregroundStyle(.black)
                                )
                            Text(shortEventTitle(event))
                                .font(.caption)
                                .foregroundStyle(.black.opacity(0.65))
                                .lineLimit(1)
                        }
                        .frame(width: 72)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 2)
            .padding(.bottom, 10)
        }
    }
    
    private var timelineSchedule: some View {
        VStack(spacing: 16) {
            ForEach(Array(timelineEvents.enumerated()), id: \.element.id) { index, event in
                HStack(alignment: .top, spacing: 12) {
                    Text(timeLabel(for: event.startTime, fallbackIndex: index))
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .frame(width: 56, alignment: .leading)
                        .padding(.top, 10)
                    
                    Button {
                        selectedEvent = event
                    } label: {
                        CommunityTimelineCard(
                            event: event,
                            onChatIconTap: {
                                showPourCircle = true
                            }
                        )
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 36)
    }
    
    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func dayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    
    private func shortEventTitle(_ event: UNPEvent) -> String {
        event.name.components(separatedBy: " ").first ?? "Event"
    }
    
    private var formattedSelectedDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd"
        return formatter.string(from: selectedDay)
    }
    
    private func timeLabel(for date: Date, fallbackIndex: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let candidate = formatter.string(from: date)
        if candidate.isEmpty {
            let base = 9 + fallbackIndex
            return String(format: "%02d:00 AM", min(base, 11))
        }
        return candidate
    }
}

private struct CommunityTimelineCard: View {
    @EnvironmentObject private var store: UNPDataStore
    let event: UNPEvent
    let onChatIconTap: () -> Void

    private var latest: UNPCommunityMessage? {
        store.messages(for: event.id).last
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: -8) {
                ForEach(0..<4, id: \.self) { idx in
                    Circle()
                        .strokeBorder(UNPColors.accent.opacity(0.45), lineWidth: 1.5)
                        .background(Circle().fill(UNPColors.cardSurface))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(UNPColors.accent.opacity(0.55 + Double(idx) * 0.1))
                        )
                }
                Spacer()
                Button(action: onChatIconTap) {
                    Circle()
                        .fill(UNPColors.cardSurface)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Image(systemName: "message.fill")
                                .font(.caption)
                                .foregroundStyle(UNPColors.accent)
                        )
                }
                .buttonStyle(.plain)
            }

            Text(event.name)
                .font(.title3.bold())
                .foregroundStyle(UNPColors.accent)
                .lineLimit(2)

            Text(latest?.text ?? "Tap to join this event chat and share your experience.")
                .font(.subheadline)
                .foregroundStyle(UNPColors.accent.opacity(0.78))
                .lineLimit(2)

            HStack {
                Text(event.venueName)
                    .font(.caption)
                    .foregroundStyle(UNPColors.accent.opacity(0.65))
                Spacer()
                if store.messages(for: event.id).count > 0 {
                    Text("\(store.messages(for: event.id).count) msgs")
                        .font(.caption2.bold())
                        .foregroundStyle(UNPColors.accent)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(UNPColors.background)
        .clipShape(RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: UNPRadius.card, style: .continuous)
                .strokeBorder(UNPColors.accent.opacity(0.22), lineWidth: 1)
        )
    }
}

struct CommunityEventRoomView: View {
    @EnvironmentObject private var store: UNPDataStore
    @Environment(\.dismiss) private var dismiss
    let event: UNPEvent
    
    @StateObject private var imageStore = UNPEventImageStore.shared
    @State private var composedMessage = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    private var messages: [UNPCommunityMessage] { store.messages(for: event.id) }
    private var eventImages: [UIImage] { imageStore.images(for: event.id) }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(event.venueName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    eventGallery
                    
                    ForEach(messages) { message in
                        CommunityMessageBubble(
                            message: message,
                            isCurrentUser: message.authorName == store.user.displayName
                        )
                    }
                }
                .padding(16)
            }
            
            composer
                .padding(12)
                .background(.ultraThinMaterial)
        }
        .navigationTitle(event.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        imageStore.add(image, to: event.id)
                    }
                }
                await MainActor.run {
                    selectedPhotoItem = nil
                }
            }
        }
    }
    
    private var eventGallery: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Group Images")
                    .font(.headline)
                Spacer()
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("Add", systemImage: "photo.badge.plus")
                        .font(.subheadline.weight(.semibold))
                }
            }
            
            if eventImages.isEmpty {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.15))
                    .frame(height: 80)
                    .overlay(Text("No images yet for this event").foregroundStyle(.secondary))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(eventImages.enumerated()), id: \.offset) { _, image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
        }
    }
    
    private var composer: some View {
        HStack(spacing: 10) {
            TextField("Share your experience...", text: $composedMessage)
                .textFieldStyle(.roundedBorder)
            
            Button("Send") {
                store.postCommunityMessage(
                    eventId: event.id,
                    authorName: store.user.displayName,
                    text: composedMessage
                )
                composedMessage = ""
            }
            .buttonStyle(.borderedProminent)
            .disabled(composedMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
}

struct UNPEventCommunityRoomView: View {
    let event: UNPEvent

    var body: some View {
        CommunityEventRoomView(event: event)
    }
}

private struct CommunityMessageBubble: View {
    let message: UNPCommunityMessage
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            VStack(alignment: .leading, spacing: 4) {
                Text(message.authorName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(message.text)
                    .font(.body)
                Text(timestampText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(isCurrentUser ? Color.black.opacity(0.1) : Color.secondary.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            if !isCurrentUser { Spacer() }
        }
    }
    
    private var timestampText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: message.timestamp)
    }
}

#Preview {
    CommunityView()
        .environmentObject(AppTheme.shared)
        .environmentObject(UNPDataStore.shared)
}

final class UNPEventImageStore: ObservableObject {
    static let shared = UNPEventImageStore()

    @Published private var eventImages: [UUID: [UIImage]] = [:]

    private init() {}

    func images(for eventId: UUID) -> [UIImage] {
        eventImages[eventId] ?? []
    }

    func add(_ image: UIImage, to eventId: UUID) {
        var images = eventImages[eventId] ?? []
        images.append(image)
        eventImages[eventId] = images
    }
}

import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager

    var categoriesWithItems: [(ItemCategory, Int)] {
        ItemCategory.allCases.compactMap { category in
            let count = clipboardManager.items(for: category).count
            return count > 0 ? (category, count) : nil
        }
    }

    var body: some View {
        if categoriesWithItems.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "folder")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("No categories yet")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("Clips are automatically categorized by AI")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(categoriesWithItems, id: \.0) { category, count in
                    NavigationLink {
                        CategoryDetailView(category: category)
                    } label: {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(categoryColor(category).opacity(0.15))
                                    .frame(width: 36, height: 36)

                                Image(systemName: category.icon)
                                    .foregroundStyle(categoryColor(category))
                            }

                            VStack(alignment: .leading) {
                                Text(category.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("\(count) clips")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    private func categoryColor(_ category: ItemCategory) -> Color {
        switch category {
        case .uncategorized: return .gray
        case .work: return .blue
        case .personal: return .green
        case .development: return .purple
        case .research: return .orange
        case .communication: return .teal
        case .finance: return .yellow
        case .social: return .pink
        case .shopping: return .red
        }
    }
}

struct CategoryDetailView: View {
    let category: ItemCategory
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var selectedItem: ClipboardItem?

    var items: [ClipboardItem] {
        clipboardManager.items(for: category)
    }

    var body: some View {
        List(items, id: \.id) { item in
            NavigationLink {
                DetailView(item: item)
            } label: {
                ClipboardItemRow(item: item)
            }
        }
        .listStyle(.plain)
        .navigationTitle(category.displayName)
    }
}

import SwiftUI

struct TableDetailsView: View {
    let columns: [String]
    let rows: [[String]]
    let database: String
    let table: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if rows.isEmpty {
                Text("Empty table")
                    .foregroundColor(.secondary)
                    .padding()
                Spacer()
            } else {
                ScrollView([.horizontal, .vertical]) {
                    VStack(alignment: .leading) {
                        HStack {
                            ForEach(columns, id: \.self) { col in
                                Text(col)
                                    .bold()
                                    .frame(minWidth: 140, alignment: .center)
                                    .padding(10)
                            }
                        }
                        Divider()
                        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                            HStack {
                                ForEach(row, id: \.self) { val in
                                    Text(val)
                                        .frame(minWidth: 140, alignment: .center)
                                        .padding(10)
                                }
                            }
                            Divider()
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

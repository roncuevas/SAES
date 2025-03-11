import SwiftUI

struct NoContentView: View {
    var title: String = "No se encontraron datos"
    var icon: Image = Image(systemName: "exclamationmark.triangle.fill")
    var action: () -> Void
    
    var body: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView {
                Label( title: {
                    Text(title)
                }, icon: {
                    icon
                        .foregroundStyle(.saes)
                        .tint(.saes)
                })
            } description: {
                Text("Puede que haya un problema con la conexion a internet o que no se haya encontrado informacion.")
            } actions: {
                Button("Reintentar", action: action)
                    .buttonStyle(.borderedProminent)
            }
        } else {
            Label( title: {
                Text(title)
            }, icon: {
                icon
            })
        }
    }
}

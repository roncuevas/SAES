import EventKit
import EventKitUI
import Routing
import SwiftUI
import WebViewAMC

struct ScheduleView: View {
    @AppStorage("boleta") private var boleta: String = ""
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @State private var store = EKEventStore()
    @State private var showEventEditViewController: Bool = false
    @State private var editingEvent: EKEvent?
    @State private var showEventAlert: Bool = false
    @State private var showEventTitle: String = "Default message"
    @State private var showEventMessage: String = ""
    @State private var isRunningSchedule: Bool = false
    
    var body: some View {
        content
            .onReceive(WebViewManager.shared.fetcher.tasksRunning) { tasks in
                self.isRunningSchedule = tasks.contains { $0 == "schedule" }
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if !webViewMessageHandler.schedule.isEmpty {
            VStack(alignment: .leading) {
                List {
                    ForEach(EventManager.weekDays, id: \.self) { dia in
                        if let materias = webViewMessageHandler.horarioSemanal.horarioPorDia[dia] {
                            Section(header: Text(dia)) {
                                getViews(dia: dia, materias: materias)
                            }
                        }
                    }
                }
                .refreshable {
                    webViewMessageHandler.schedule = []
                    webViewMessageHandler.horarioSemanal = HorarioSemanal()
                    WebViewActions.shared.schedule()
                }
            }
            .errorLoadingAlert(
                isPresented: $webViewMessageHandler.isErrorPage,
                webViewManager: WebViewManager.shared
            )
            .alert(
                showEventTitle, isPresented: $showEventAlert,
                actions: {
                    Button("Ok") {
                        showEventAlert = false
                    }
                },
                message: {
                    Text(showEventMessage)
                }
            )
            .sheet(isPresented: $showEventEditViewController) {
                AddEvent(event: $editingEvent)
            }
        } else if isRunningSchedule {
            SearchingView(title: "Buscando horario...")
        } else {
            NoContentView {
                WebViewActions.shared.schedule()
            }
        }
    }
    
    @ViewBuilder
    private func getViews(
        dia: String,
        materias: [MateriaConHoras]
    ) -> some View {
        let materiasSortedByHour = materias.sorted(by: {
            RangoHorario.esMenorQue($0.horas.first, $1.horas.first)
        })
        ForEach(materiasSortedByHour, id: \.materia) { materia in
            HStack {
                VStack(alignment: .leading) {
                    Text(materia.materia).font(.headline)
                    ForEach(materia.horas, id: \.inicio) { rango in
                        Text("\(rango.inicio) - \(rango.fin)").font(
                            .subheadline)
                    }
                }
                Spacer()
                Button {
                    editingEvent = EventManager.getWeeklyEvent(
                        eventStore: EventManager.shared.eventStore,
                        eventTitle: "Clase de \(materia.materia)",
                        startingOnDayOfWeek: dia,
                        startTime: materia.horas.first?.inicio,
                        endTime: materia.horas.last?.fin,
                        until: Date.now.addingTimeInterval(1_209_600))
                    // showEventEditViewController = true
                    guard let editingEvent else { return }
                    saveEvent(event: editingEvent)
                } label: {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 28, weight: .light))
                        .tint(.black)
                }
                .padding(.trailing, 8)
            }
        }
    }

    private func saveEvent(event: EKEvent) {
        EventManager.shared.eventStore.requestAccess(to: .event) { (granted, error) in
            if granted && error == nil {
                do {
                    try EventManager.shared.eventStore.save(
                        event, span: .thisEvent)
                    showEventTitle = "Evento guardado correctamente"
                    showEventMessage =
                        "\(String(describing: event.title)) desde \(String(describing: event.startDate)) hasta \(String(describing: event.endDate))"
                } catch let error as NSError {
                    showEventTitle = "Error al guardar el evento: \(error)"
                }
            } else {
                showEventTitle =
                    "Acceso al calendario denegado o error: \(String(describing: error))"
            }
            showEventAlert = true
        }
    }
}

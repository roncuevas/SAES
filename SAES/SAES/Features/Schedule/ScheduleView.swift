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
    @State private var showEventTitle: String = ""
    @State private var showEventMessage: String = ""
    @State private var isRunningSchedule: Bool = false
    
    var body: some View {
        content
            .onReceive(WebViewManager.shared.fetcher.tasksRunning) { tasks in
                self.isRunningSchedule = tasks.contains { $0 == "schedule" }
            }
            .errorLoadingAlert(
                isPresented: $webViewMessageHandler.isErrorPage,
                webViewManager: WebViewManager.shared
            )
            .alert(
                showEventTitle, isPresented: $showEventAlert,
                actions: {
                    Button(Localization.okey) {
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
            .refreshable {
                webViewMessageHandler.schedule = []
                webViewMessageHandler.horarioSemanal = HorarioSemanal()
                WebViewActions.shared.schedule()
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if !webViewMessageHandler.schedule.isEmpty {
            List {
                ForEach(EventManager.weekDays, id: \.self) { dia in
                    if let materias = webViewMessageHandler.horarioSemanal.horarioPorDia[dia] {
                        Section(header: Text(dia)) {
                            getViews(dia: dia, materias: materias)
                        }
                    }
                }
            }
        } else if isRunningSchedule {
            SearchingView(title: Localization.searching)
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
                        Text(rango.inicio + " - " + rango.fin)
                            .font(.subheadline)
                    }
                }
                Spacer()
                Button {
                    editingEvent = EventManager.getWeeklyEvent(
                        eventStore: EventManager.shared.eventStore,
                        eventTitle: Localization.subject.colon.space + materia.materia,
                        startingOnDayOfWeek: dia,
                        startTime: materia.horas.first?.inicio,
                        endTime: materia.horas.last?.fin,
                        until: Date.now.addingTimeInterval(1_209_600)
                    )
                    // showEventEditViewController = true
                    guard let editingEvent else { return }
                    // saveEvent(event: editingEvent)
                } label: {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundStyle(.saes)
                        .font(.system(size: 28, weight: .light))
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
                    showEventTitle = Localization.eventSavedCorrectly
                    showEventMessage = String(describing: event.title).space + Localization.fromText.space +
                    String(describing: event.startDate).space + Localization.toText.space + String(describing: event.endDate)
                } catch let error as NSError {
                    showEventTitle = Localization.errorSavingEvent.space + error.localizedDescription
                }
            } else {
                showEventTitle = Localization.errorAccessingCalendar.space + String(describing: error)
            }
            showEventAlert = true
        }
    }
}

extension Localization {
    static let eventSavedCorrectly = NSLocalizedString("Event saved correctly", comment: "")
    static let fromText = NSLocalizedString("From", comment: "")
    static let toText = NSLocalizedString("To", comment: "")
    static let errorSavingEvent = NSLocalizedString("Error saving event", comment: "")
    static let errorAccessingCalendar = NSLocalizedString("Error accessing calendar", comment: "")
}

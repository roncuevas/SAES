import SwiftUI
import Routing
import EventKit
import EventKitUI

struct ScheduleView: View {
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("boleta") private var boleta: String = ""
    @Binding var selectedTab: LoggedTabs
    @EnvironmentObject private var webViewManager: WebViewManager
    @EnvironmentObject private var webViewMessageHandler: WebViewMessageHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @State private var store = EKEventStore()
    @State private var showEventEditViewController: Bool = false
    private let webViewDataFetcher: WebViewDataFetcher = WebViewDataFetcher()
    let diasDeLaSemana = ["Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado"]
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(diasDeLaSemana, id: \.self) { dia in
                    // Asegúrate de que solo se cree una sección si hay materias ese día
                    if let materias = webViewMessageHandler.horarioSemanal.horarioPorDia[dia] {
                        Section(header: Text(dia)) {
                            ForEach(materias.sorted(by: { RangoHorario.esMenorQue($0.horas.first, $1.horas.first)}), id: \.materia) { materia in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(materia.materia).font(.headline)
                                        ForEach(materia.horas, id: \.inicio) { rango in
                                            Text("\(rango.inicio) - \(rango.fin)").font(.subheadline)
                                        }
                                    }
                                    Spacer()
                                    Button {
                                        for rango in materia.horas {
                                            addWeeklyEvent(startingOnDayOfWeek: dia, startTime: rango.inicio, endTime: rango.fin, until: Date.now.addingTimeInterval(1209600))
                                        }
                                        showEventEditViewController = true
                                    } label: {
                                        Image(systemName: "calendar.badge.plus")
                                            .font(.system(size: 28, weight: .light))
                                            .tint(.red)
                                    }
                                    .padding(.trailing, 8)
                                }
                            }
                        }
                    }
                }
            }
            .refreshable {
                webViewMessageHandler.schedule = []
                webViewMessageHandler.horarioSemanal = HorarioSemanal()
                await webViewDataFetcher.fetchSchedule()
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            guard selectedTab == .schedules else { return }
            webViewManager.loadURL(url: .schedule)
        }
        .task {
            guard selectedTab == .schedules else { return }
            await webViewDataFetcher.fetchSchedule()
        }
        .alert("Error cargando la pagina", isPresented: $webViewMessageHandler.isErrorPage) {
            Button("Ok") {
                webViewManager.loadURL(url: .base)
            }
        }
        .sheet(isPresented: $showEventEditViewController) {
            AddEvent(event: nil)
        }
    }
    
    private func addWeeklyEvent(startingOnDayOfWeek dayOfWeek: String, startTime: String, endTime: String, until endDate: Date?) {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted && error == nil {
                // Determinar la próxima fecha del día de la semana especificado
                let nextDayOfWeekDate = getNextDayOfWeek(dayOfWeek, startTime: startTime)
                
                // Crear un nuevo evento
                let event = EKEvent(eventStore: eventStore)
                event.calendar = eventStore.defaultCalendarForNewEvents
                event.title = "Mi Evento Semanal"
                event.startDate = nextDayOfWeekDate
                event.endDate = nextDayOfWeekDate.addingTimeInterval(getDuration(startTime: startTime, endTime: endTime))
                
                // Configurar la regla de recurrencia hasta una fecha específica
                var recurrenceEnd: EKRecurrenceEnd? = nil
                if let endDate {
                    recurrenceEnd = EKRecurrenceEnd(end: endDate)
                }
                let recurrenceRule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: recurrenceEnd)
                event.addRecurrenceRule(recurrenceRule)
                
                // Guardar el evento en el calendario
                do {
                    try eventStore.save(event, span: .thisEvent)
                    print("Evento guardado correctamente")
                } catch let error as NSError {
                    print("Error al guardar el evento: \(error)")
                }
            } else {
                print("Acceso al calendario denegado o error: \(String(describing: error))")
            }
        }
    }
    
    func getNextDayOfWeek(_ dayOfWeek: String, startTime: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        guard let startTimeDate = dateFormatter.date(from: startTime) else { return Date() }
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute], from: startTimeDate)
        
        var weekDay: Int = 0
        switch dayOfWeek.lowercased() {
            case "domingo": weekDay = 1
            case "lunes": weekDay = 2
            case "martes": weekDay = 3
            case "miercoles": weekDay = 4
            case "jueves": weekDay = 5
            case "viernes": weekDay = 6
            case "sabado": weekDay = 7
            default: break
        }
        
        components.weekday = weekDay
        
        let today = Date()
        var nextDate = calendar.nextDate(after: today, matching: components, matchingPolicy: .nextTime)!
        if nextDate < today {
            // Si el día ya pasó esta semana, calcula para la próxima semana.
            nextDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: nextDate)!
        }
        
        return nextDate
    }
    
    func getDuration(startTime: String, endTime: String) -> TimeInterval {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        guard let startDateTime = dateFormatter.date(from: startTime),
              let endDateTime = dateFormatter.date(from: endTime) else {
                  return 0
              }
        
        return endDateTime.timeIntervalSince(startDateTime)
    }
}

struct RangoHorario {
    var inicio: String
    var fin: String
    
    // Función para convertir un horario de tipo String a minutos desde medianoche.
    func minutosDesdeMedianocheDe(_ horario: String) -> Int {
        let componentes = horario.split(separator: ":").map { Int($0) ?? 0 }
        return (componentes[0] * 60) + componentes[1] // Horas * 60 + minutos
    }
    
    // Función para comparar si un rango inicia antes que otro basado en la hora de inicio.
    static func esMenorQue(_ lhs: RangoHorario?, _ rhs: RangoHorario?) -> Bool {
        guard let lhs, let rhs else { return false }
        return lhs.minutosDesdeMedianocheDe(lhs.inicio) < rhs.minutosDesdeMedianocheDe(rhs.inicio)
    }
}

struct MateriaConHoras {
    var materia: String
    var horas: [RangoHorario]  // Usamos String para manejar correctamente las horas y minutos
}

struct HorarioSemanal {
    var horarioPorDia: [String: [MateriaConHoras]] = [:]
    
    mutating func agregarMateria(dia: String, materia: String, rangoHoras: String) {
        // Convertir el rango de horas en un arreglo de horas
        let horas = convertirRangoEnHorarios(rangoHoras: rangoHoras)
        
        // Crear o actualizar la lista de materias para el día dado
        let materiaConHoras = MateriaConHoras(materia: materia, horas: horas)
        if horarioPorDia[dia] != nil {
            horarioPorDia[dia]?.append(materiaConHoras)
        } else {
            horarioPorDia[dia] = [materiaConHoras]
        }
    }
    
    func convertirRangoEnHorarios(rangoHoras: String) -> [RangoHorario] {
        var rangosHorarios: [RangoHorario] = []
        
        // Divide la cadena en componentes separados por espacios
        let componentes = rangoHoras.split(separator: " ").map(String.init)
        var rangoTemporal: [String] = []

        for componente in componentes {
            // Agrega el componente actual al rango temporal
            rangoTemporal.append(componente)

            // Si el rango temporal tiene 2 elementos (inicio y fin), procesa este rango
            if rangoTemporal.count == 3 {
                let inicio = rangoTemporal[0]
                let fin = rangoTemporal[2]

                // Crea un nuevo RangoHorario y lo añade a la lista
                let rangoHorario = RangoHorario(inicio: inicio, fin: fin)
                rangosHorarios.append(rangoHorario)

                // Reinicia el rango temporal usando el fin como el nuevo inicio
                // Esto permite manejar cadenas con múltiples rangos
                rangoTemporal.removeAll()
            }
        }

        return rangosHorarios
    }
}

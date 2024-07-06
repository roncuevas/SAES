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
    @State private var editingEvent: EKEvent?
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(EventManager.weekDays, id: \.self) { dia in
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
                                        editingEvent = EventManager.getWeeklyEvent(eventTitle: "Clase de \(materia.materia)",
                                                                                   startingOnDayOfWeek: dia,
                                                                                   startTime: materia.horas.first?.inicio,
                                                                                   endTime: materia.horas.last?.fin,
                                                                                   until: Date.now.addingTimeInterval(1209600))
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
            AddEvent(event: $editingEvent)
        }
    }
    
    private func saveEvent() {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted && error == nil {
                // Guardar el evento en el calendario
                do {
                    // try eventStore.save(event, span: .thisEvent)
                    print("Evento guardado correctamente")
                } catch let error as NSError {
                    print("Error al guardar el evento: \(error)")
                }
            } else {
                print("Acceso al calendario denegado o error: \(String(describing: error))")
            }
        }
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

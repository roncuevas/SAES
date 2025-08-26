import Foundation

enum ScheduleAvailabilityField: String, CaseIterable {
    case career
    case shift
    case periods
    case studyPlan
    case schoolPeriodGroup
    case sequences
    case visualize

    var selector: SAESSelector {
        return switch self {
        case .career:
            SAESSelector(type: "select", idSelector: "ctl00_mainCopy_Filtro_cboCarrera", name: "ctl00$mainCopy$Filtro$cboCarrera")
        case .shift:
            SAESSelector(type: "select", idSelector: "ctl00_mainCopy_Filtro_cboTurno", name: "ctl00$mainCopy$Filtro$cboTurno")
        case .periods:
            SAESSelector(type: "select", idSelector: "ctl00_mainCopy_Filtro_lsNoPeriodos", name: "ctl00$mainCopy$Filtro$lsNoPeriodos")
        case .studyPlan:
            SAESSelector(type: "select", idSelector: "ctl00_mainCopy_Filtro_cboPlanEstud", name: "ctl00$mainCopy$Filtro$cboPlanEstud")
        case .schoolPeriodGroup:
            SAESSelector(type: "input", idSelector: "ctl00_mainCopy_optActual", name: "ctl00$mainCopy$GroupPeriodoEscolar")
        case .sequences:
            SAESSelector(type: "select", idSelector: "ctl00_mainCopy_lsSecuencias", name: "ctl00$mainCopy$lsSecuencias")
        case .visualize:
            SAESSelector(type: "input", idSelector: "ctl00_mainCopy_cmdVisalizar", name: "ctl00$mainCopy$cmdVisalizar")
        }
    }
}

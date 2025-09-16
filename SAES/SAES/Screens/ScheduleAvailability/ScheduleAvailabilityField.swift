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
            SAESSelector(type: "select", selector: "#ctl00_mainCopy_Filtro_cboCarrera")
        case .shift:
            SAESSelector(type: "select", selector: "#ctl00_mainCopy_Filtro_cboTurno")
        case .periods:
            SAESSelector(type: "select", selector: "#ctl00_mainCopy_Filtro_lsNoPeriodos")
        case .studyPlan:
            SAESSelector(type: "select", selector: "#ctl00_mainCopy_Filtro_cboPlanEstud")
        case .schoolPeriodGroup:
            SAESSelector(type: "input", selector: "#ctl00_mainCopy_optActual")
        case .sequences:
            SAESSelector(type: "select", selector: "#ctl00_mainCopy_lsSecuencias")
        case .visualize:
            SAESSelector(type: "input", selector: "#ctl00_mainCopy_cmdVisalizar")
        }
    }

    var name: String {
        return switch self {
        case .career: "ctl00$mainCopy$Filtro$cboCarrera"
        case .shift: "ctl00$mainCopy$Filtro$cboTurno"
        case .periods: "ctl00$mainCopy$Filtro$lsNoPeriodos"
        case .studyPlan: "ctl00$mainCopy$Filtro$cboPlanEstud"
        case .schoolPeriodGroup: "ctl00$mainCopy$GroupPeriodoEscolar"
        case .sequences: "ctl00$mainCopy$lsSecuencias"
        case .visualize: "ctl00$mainCopy$cmdVisalizar"
        }
    }
}

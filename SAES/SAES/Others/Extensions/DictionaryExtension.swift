extension Dictionary where Key == String, Value == String {
    var hasPersonalData: Bool {
        self["name"]?.isEmpty == false
    }
    
    mutating func clearPersonalData() {
        self.removeValue(forKey: "studentID")
        self.removeValue(forKey: "name")
        self.removeValue(forKey: "curp")
        self.removeValue(forKey: "rfc")
        self.removeValue(forKey: "campus")
        self.removeValue(forKey: "militaryID")
        self.removeValue(forKey: "email")
    }
}

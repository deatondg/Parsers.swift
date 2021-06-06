extension Result where Failure == Never {
    func get() -> Success {
        switch self {
        case .success(let success):
            return success
        }
    }
}

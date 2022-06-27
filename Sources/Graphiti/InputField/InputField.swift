import GraphQL

public class InputField<InputObjectType, Context, FieldType> : InputFieldComponent<InputObjectType, Context> {
    let name: String
    var defaultValue: AnyEncodable?
    
    override func field(typeProvider: TypeProvider) throws -> (String, InputObjectField) {
        let field = InputObjectField(
            type: try typeProvider.getInputType(from: FieldType.self, field: name),
            defaultValue: try defaultValue.map {
                try MapEncoder().encode($0)
            },
            description: description
        )
        
        return (self.name, field)
    }
    
    init(
        name: String
    ) {
        self.name = name
    }
}

public extension InputField {
    convenience init(
        _ name: String,
        at keyPath: KeyPath<InputObjectType, FieldType>
    ) {
        self.init(name: name)
    }
}

public extension InputField {
    convenience init<KeyPathType>(
        _ name: String,
        at keyPath: KeyPath<InputObjectType, KeyPathType>,
        as: FieldType.Type
    ) {
        self.init(name: name)
    }
}

public extension InputField where FieldType : Encodable {
    func defaultValue(_ defaultValue: FieldType) -> Self {
        self.defaultValue = AnyEncodable(defaultValue)
        return self
    }
}

import GraphQL

public final class Enum<RootType, Context, EnumType : Encodable & RawRepresentable> : Component<RootType, Context> where EnumType.RawValue == String {
    private let values: [String: EnumType]
    
    override func update(builder: SchemaBuilder) throws {
        let enumType = try GraphQLEnumType(
            name: name,
            description: description,
            values: values.reduce(into: [:]) { result, value in
                
                result[value.key] = GraphQLEnumValue(
                    value: Map(stringLiteral: value.key),
                    description: "",
                    deprecationReason: ""
                )
            }
        )
        
        try builder.map(EnumType.self, to: enumType)
    }
    
    init(
        type: EnumType.Type,
        name: String?,
        values: [String: EnumType]
    ) {
        self.values = values
        super.init(name: name ?? Reflection.name(for: EnumType.self))
    }
}

extension Enum {
    public convenience init(
        _ type: EnumType.Type,
        as name: String? = nil,
        _ values: [String: EnumType]
    ) {
        self.init(type: type, name: name, values: values)
    }
}

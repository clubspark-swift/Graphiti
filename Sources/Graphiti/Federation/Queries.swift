import GraphQL
import NIO

let resolveReferenceFieldName = "__resolveReference"

func serviceQuery(for sdl: String) -> GraphQLField {
    return GraphQLField(
        type: GraphQLNonNull(serviceType),
        description: "Return the SDL string for the subschema",
        resolve: { source, args, context, eventLoopGroup, info in
            let result = Service(sdl: sdl)
            return eventLoopGroup.any().makeSucceededFuture(result)
        }
    )
}

func entitiesQuery(for federatedTypes: [GraphQLObjectType], entityType: GraphQLUnionType, coders: Coders) -> GraphQLField {
    return GraphQLField(
        type: GraphQLNonNull(GraphQLList(entityType)),
        description: "Return all entities matching the provided representations.",
        args: ["representations": GraphQLArgument(type: GraphQLNonNull(GraphQLList(GraphQLNonNull(anyType))))],
        resolve: { source, args, context, eventLoopGroup, info in
            let arguments = try coders.decoder.decode(EntityArguments.self, from: args)
            let futures: [EventLoopFuture<Any?>] = try arguments.representations.map { (representationMap: Map) in
                let representation = try coders.decoder.decode(
                    EntityRepresentation.self,
                    from: representationMap
                )
                guard let type = federatedTypes.first(where: { value in value.name == representation.__typename }) else {
                    throw GraphQLError(message: "Federated type not found: \(representation.__typename)")
                }
                guard let resolve = type.fields[resolveReferenceFieldName]?.resolve else {
                    throw GraphQLError(
                        message: "Federated type has no '__resolveReference' field resolver: \(type.name)"
                    )
                }
                return try resolve(
                    source,
                    representationMap,
                    context,
                    eventLoopGroup,
                    info
                )
            }

            return futures.flatten(on: eventLoopGroup)
                .map { $0 as Any? }
        }
    )
}

//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import GRDB
import SignalCoreKit

// NOTE: This file is generated by /Scripts/sds_codegen/sds_generate.py.
// Do not manually edit it, instead run `sds_codegen.sh`.

// MARK: - Record

public struct ThreadRecord: SDSRecord {
    public weak var delegate: SDSRecordDelegate?

    public var tableMetadata: SDSTableMetadata {
        return TSThreadSerializer.table
    }

    public static let databaseTableName: String = TSThreadSerializer.table.tableName

    public var id: Int64?

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    public let recordType: SDSRecordType
    public let uniqueId: String

    // Properties
    public let conversationColorName: String
    public let creationDate: Double?
    public let isArchived: Bool
    public let lastInteractionRowId: Int64
    public let messageDraft: String?
    public let mutedUntilDate: Double?
    public let shouldThreadBeVisible: Bool
    public let contactPhoneNumber: String?
    public let contactUUID: String?
    public let groupModel: Data?
    public let hasDismissedOffers: Bool?

    public enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case recordType
        case uniqueId
        case conversationColorName
        case creationDate
        case isArchived
        case lastInteractionRowId
        case messageDraft
        case mutedUntilDate
        case shouldThreadBeVisible
        case contactPhoneNumber
        case contactUUID
        case groupModel
        case hasDismissedOffers
    }

    public static func columnName(_ column: ThreadRecord.CodingKeys, fullyQualified: Bool = false) -> String {
        return fullyQualified ? "\(databaseTableName).\(column.rawValue)" : column.rawValue
    }

    public func didInsert(with rowID: Int64, for column: String?) {
        guard let delegate = delegate else {
            owsFailDebug("Missing delegate.")
            return
        }
        delegate.updateRowId(rowID)
    }
}

// MARK: - Row Initializer

public extension ThreadRecord {
    static var databaseSelection: [SQLSelectable] {
        return CodingKeys.allCases
    }

    init(row: Row) {
        id = row[0]
        recordType = row[1]
        uniqueId = row[2]
        conversationColorName = row[3]
        creationDate = row[4]
        isArchived = row[5]
        lastInteractionRowId = row[6]
        messageDraft = row[7]
        mutedUntilDate = row[8]
        shouldThreadBeVisible = row[9]
        contactPhoneNumber = row[10]
        contactUUID = row[11]
        groupModel = row[12]
        hasDismissedOffers = row[13]
    }
}

// MARK: - StringInterpolation

public extension String.StringInterpolation {
    mutating func appendInterpolation(threadColumn column: ThreadRecord.CodingKeys) {
        appendLiteral(ThreadRecord.columnName(column))
    }
    mutating func appendInterpolation(threadColumnFullyQualified column: ThreadRecord.CodingKeys) {
        appendLiteral(ThreadRecord.columnName(column, fullyQualified: true))
    }
}

// MARK: - Deserialization

// TODO: Rework metadata to not include, for example, columns, column indices.
extension TSThread {
    // This method defines how to deserialize a model, given a
    // database row.  The recordType column is used to determine
    // the corresponding model class.
    class func fromRecord(_ record: ThreadRecord) throws -> TSThread {

        guard let recordId = record.id else {
            throw SDSError.invalidValue
        }

        switch record.recordType {
        case .contactThread:

            let uniqueId: String = record.uniqueId
            let conversationColorName: ConversationColorName = ConversationColorName(rawValue: record.conversationColorName)
            let creationDateInterval: Double? = record.creationDate
            let creationDate: Date? = SDSDeserialization.optionalDoubleAsDate(creationDateInterval, name: "creationDate")
            let isArchived: Bool = record.isArchived
            let lastInteractionRowId: Int64 = record.lastInteractionRowId
            let messageDraft: String? = record.messageDraft
            let mutedUntilDateInterval: Double? = record.mutedUntilDate
            let mutedUntilDate: Date? = SDSDeserialization.optionalDoubleAsDate(mutedUntilDateInterval, name: "mutedUntilDate")
            let shouldThreadBeVisible: Bool = record.shouldThreadBeVisible
            let contactPhoneNumber: String? = record.contactPhoneNumber
            let contactUUID: String? = record.contactUUID
            let hasDismissedOffers: Bool = try SDSDeserialization.required(record.hasDismissedOffers, name: "hasDismissedOffers")

            return TSContactThread(grdbId: recordId,
                                   uniqueId: uniqueId,
                                   conversationColorName: conversationColorName,
                                   creationDate: creationDate,
                                   isArchived: isArchived,
                                   lastInteractionRowId: lastInteractionRowId,
                                   messageDraft: messageDraft,
                                   mutedUntilDate: mutedUntilDate,
                                   shouldThreadBeVisible: shouldThreadBeVisible,
                                   contactPhoneNumber: contactPhoneNumber,
                                   contactUUID: contactUUID,
                                   hasDismissedOffers: hasDismissedOffers)

        case .groupThread:

            let uniqueId: String = record.uniqueId
            let conversationColorName: ConversationColorName = ConversationColorName(rawValue: record.conversationColorName)
            let creationDateInterval: Double? = record.creationDate
            let creationDate: Date? = SDSDeserialization.optionalDoubleAsDate(creationDateInterval, name: "creationDate")
            let isArchived: Bool = record.isArchived
            let lastInteractionRowId: Int64 = record.lastInteractionRowId
            let messageDraft: String? = record.messageDraft
            let mutedUntilDateInterval: Double? = record.mutedUntilDate
            let mutedUntilDate: Date? = SDSDeserialization.optionalDoubleAsDate(mutedUntilDateInterval, name: "mutedUntilDate")
            let shouldThreadBeVisible: Bool = record.shouldThreadBeVisible
            let groupModelSerialized: Data? = record.groupModel
            let groupModel: TSGroupModel = try SDSDeserialization.unarchive(groupModelSerialized, name: "groupModel")

            return TSGroupThread(grdbId: recordId,
                                 uniqueId: uniqueId,
                                 conversationColorName: conversationColorName,
                                 creationDate: creationDate,
                                 isArchived: isArchived,
                                 lastInteractionRowId: lastInteractionRowId,
                                 messageDraft: messageDraft,
                                 mutedUntilDate: mutedUntilDate,
                                 shouldThreadBeVisible: shouldThreadBeVisible,
                                 groupModel: groupModel)

        case .thread:

            let uniqueId: String = record.uniqueId
            let conversationColorName: ConversationColorName = ConversationColorName(rawValue: record.conversationColorName)
            let creationDateInterval: Double? = record.creationDate
            let creationDate: Date? = SDSDeserialization.optionalDoubleAsDate(creationDateInterval, name: "creationDate")
            let isArchived: Bool = record.isArchived
            let lastInteractionRowId: Int64 = record.lastInteractionRowId
            let messageDraft: String? = record.messageDraft
            let mutedUntilDateInterval: Double? = record.mutedUntilDate
            let mutedUntilDate: Date? = SDSDeserialization.optionalDoubleAsDate(mutedUntilDateInterval, name: "mutedUntilDate")
            let shouldThreadBeVisible: Bool = record.shouldThreadBeVisible

            return TSThread(grdbId: recordId,
                            uniqueId: uniqueId,
                            conversationColorName: conversationColorName,
                            creationDate: creationDate,
                            isArchived: isArchived,
                            lastInteractionRowId: lastInteractionRowId,
                            messageDraft: messageDraft,
                            mutedUntilDate: mutedUntilDate,
                            shouldThreadBeVisible: shouldThreadBeVisible)

        default:
            owsFailDebug("Unexpected record type: \(record.recordType)")
            throw SDSError.invalidValue
        }
    }
}

// MARK: - SDSModel

extension TSThread: SDSModel {
    public var serializer: SDSSerializer {
        // Any subclass can be cast to it's superclass,
        // so the order of this switch statement matters.
        // We need to do a "depth first" search by type.
        switch self {
        case let model as TSGroupThread:
            assert(type(of: model) == TSGroupThread.self)
            return TSGroupThreadSerializer(model: model)
        case let model as TSContactThread:
            assert(type(of: model) == TSContactThread.self)
            return TSContactThreadSerializer(model: model)
        default:
            return TSThreadSerializer(model: self)
        }
    }

    public func asRecord() throws -> SDSRecord {
        return try serializer.asRecord()
    }

    public var sdsTableName: String {
        return ThreadRecord.databaseTableName
    }

    public static var table: SDSTableMetadata {
        return TSThreadSerializer.table
    }
}

// MARK: - Table Metadata

extension TSThreadSerializer {

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    static let idColumn = SDSColumnMetadata(columnName: "id", columnType: .primaryKey, columnIndex: 0)
    static let recordTypeColumn = SDSColumnMetadata(columnName: "recordType", columnType: .int64, columnIndex: 1)
    static let uniqueIdColumn = SDSColumnMetadata(columnName: "uniqueId", columnType: .unicodeString, isUnique: true, columnIndex: 2)
    // Properties
    static let conversationColorNameColumn = SDSColumnMetadata(columnName: "conversationColorName", columnType: .unicodeString, columnIndex: 3)
    static let creationDateColumn = SDSColumnMetadata(columnName: "creationDate", columnType: .double, isOptional: true, columnIndex: 4)
    static let isArchivedColumn = SDSColumnMetadata(columnName: "isArchived", columnType: .int, columnIndex: 5)
    static let lastInteractionRowIdColumn = SDSColumnMetadata(columnName: "lastInteractionRowId", columnType: .int64, columnIndex: 6)
    static let messageDraftColumn = SDSColumnMetadata(columnName: "messageDraft", columnType: .unicodeString, isOptional: true, columnIndex: 7)
    static let mutedUntilDateColumn = SDSColumnMetadata(columnName: "mutedUntilDate", columnType: .double, isOptional: true, columnIndex: 8)
    static let shouldThreadBeVisibleColumn = SDSColumnMetadata(columnName: "shouldThreadBeVisible", columnType: .int, columnIndex: 9)
    static let contactPhoneNumberColumn = SDSColumnMetadata(columnName: "contactPhoneNumber", columnType: .unicodeString, isOptional: true, columnIndex: 10)
    static let contactUUIDColumn = SDSColumnMetadata(columnName: "contactUUID", columnType: .unicodeString, isOptional: true, columnIndex: 11)
    static let groupModelColumn = SDSColumnMetadata(columnName: "groupModel", columnType: .blob, isOptional: true, columnIndex: 12)
    static let hasDismissedOffersColumn = SDSColumnMetadata(columnName: "hasDismissedOffers", columnType: .int, isOptional: true, columnIndex: 13)

    // TODO: We should decide on a naming convention for
    //       tables that store models.
    public static let table = SDSTableMetadata(collection: TSThread.collection(),
                                               tableName: "model_TSThread",
                                               columns: [
        idColumn,
        recordTypeColumn,
        uniqueIdColumn,
        conversationColorNameColumn,
        creationDateColumn,
        isArchivedColumn,
        lastInteractionRowIdColumn,
        messageDraftColumn,
        mutedUntilDateColumn,
        shouldThreadBeVisibleColumn,
        contactPhoneNumberColumn,
        contactUUIDColumn,
        groupModelColumn,
        hasDismissedOffersColumn
        ])
}

// MARK: - Save/Remove/Update

@objc
public extension TSThread {
    func anyInsert(transaction: SDSAnyWriteTransaction) {
        sdsSave(saveMode: .insert, transaction: transaction)
    }

    // Avoid this method whenever feasible.
    //
    // If the record has previously been saved, this method does an overwriting
    // update of the corresponding row, otherwise if it's a new record, this
    // method inserts a new row.
    //
    // For performance, when possible, you should explicitly specify whether
    // you are inserting or updating rather than calling this method.
    func anyUpsert(transaction: SDSAnyWriteTransaction) {
        let isInserting: Bool
        if TSThread.anyFetch(uniqueId: uniqueId, transaction: transaction) != nil {
            isInserting = false
        } else {
            isInserting = true
        }
        sdsSave(saveMode: isInserting ? .insert : .update, transaction: transaction)
    }

    // This method is used by "updateWith..." methods.
    //
    // This model may be updated from many threads. We don't want to save
    // our local copy (this instance) since it may be out of date.  We also
    // want to avoid re-saving a model that has been deleted.  Therefore, we
    // use "updateWith..." methods to:
    //
    // a) Update a property of this instance.
    // b) If a copy of this model exists in the database, load an up-to-date copy,
    //    and update and save that copy.
    // b) If a copy of this model _DOES NOT_ exist in the database, do _NOT_ save
    //    this local instance.
    //
    // After "updateWith...":
    //
    // a) Any copy of this model in the database will have been updated.
    // b) The local property on this instance will always have been updated.
    // c) Other properties on this instance may be out of date.
    //
    // All mutable properties of this class have been made read-only to
    // prevent accidentally modifying them directly.
    //
    // This isn't a perfect arrangement, but in practice this will prevent
    // data loss and will resolve all known issues.
    func anyUpdate(transaction: SDSAnyWriteTransaction, block: (TSThread) -> Void) {

        block(self)

        guard let dbCopy = type(of: self).anyFetch(uniqueId: uniqueId,
                                                   transaction: transaction) else {
            return
        }

        // Don't apply the block twice to the same instance.
        // It's at least unnecessary and actually wrong for some blocks.
        // e.g. `block: { $0 in $0.someField++ }`
        if dbCopy !== self {
            block(dbCopy)
        }

        dbCopy.sdsSave(saveMode: .update, transaction: transaction)
    }

    // This method is an alternative to `anyUpdate(transaction:block:)` methods.
    //
    // We should generally use `anyUpdate` to ensure we're not unintentionally
    // clobbering other columns in the database when another concurrent update
    // has occured.
    //
    // There are cases when this doesn't make sense, e.g. when  we know we've
    // just loaded the model in the same transaction. In those cases it is
    // safe and faster to do a "overwriting" update
    func anyOverwritingUpdate(transaction: SDSAnyWriteTransaction) {
        sdsSave(saveMode: .update, transaction: transaction)
    }

    func anyRemove(transaction: SDSAnyWriteTransaction) {
        sdsRemove(transaction: transaction)
    }

    func anyReload(transaction: SDSAnyReadTransaction) {
        anyReload(transaction: transaction, ignoreMissing: false)
    }

    func anyReload(transaction: SDSAnyReadTransaction, ignoreMissing: Bool) {
        guard let latestVersion = type(of: self).anyFetch(uniqueId: uniqueId, transaction: transaction) else {
            if !ignoreMissing {
                owsFailDebug("`latest` was unexpectedly nil")
            }
            return
        }

        setValuesForKeys(latestVersion.dictionaryValue)
    }
}

// MARK: - TSThreadCursor

@objc
public class TSThreadCursor: NSObject {
    private let cursor: RecordCursor<ThreadRecord>?

    init(cursor: RecordCursor<ThreadRecord>?) {
        self.cursor = cursor
    }

    public func next() throws -> TSThread? {
        guard let cursor = cursor else {
            return nil
        }
        guard let record = try cursor.next() else {
            return nil
        }
        return try TSThread.fromRecord(record)
    }

    public func all() throws -> [TSThread] {
        var result = [TSThread]()
        while true {
            guard let model = try next() else {
                break
            }
            result.append(model)
        }
        return result
    }
}

// MARK: - Obj-C Fetch

// TODO: We may eventually want to define some combination of:
//
// * fetchCursor, fetchOne, fetchAll, etc. (ala GRDB)
// * Optional "where clause" parameters for filtering.
// * Async flavors with completions.
//
// TODO: I've defined flavors that take a read transaction.
//       Or we might take a "connection" if we end up having that class.
@objc
public extension TSThread {
    class func grdbFetchCursor(transaction: GRDBReadTransaction) -> TSThreadCursor {
        let database = transaction.database
        do {
            let cursor = try ThreadRecord.fetchCursor(database)
            return TSThreadCursor(cursor: cursor)
        } catch {
            owsFailDebug("Read failed: \(error)")
            return TSThreadCursor(cursor: nil)
        }
    }

    // Fetches a single model by "unique id".
    class func anyFetch(uniqueId: String,
                        transaction: SDSAnyReadTransaction) -> TSThread? {
        assert(uniqueId.count > 0)

        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            return TSThread.ydb_fetch(uniqueId: uniqueId, transaction: ydbTransaction)
        case .grdbRead(let grdbTransaction):
            let sql = "SELECT * FROM \(ThreadRecord.databaseTableName) WHERE \(threadColumn: .uniqueId) = ?"
            return grdbFetchOne(sql: sql, arguments: [uniqueId], transaction: grdbTransaction)
        }
    }

    // Traverses all records.
    // Records are not visited in any particular order.
    class func anyEnumerate(transaction: SDSAnyReadTransaction,
                            block: @escaping (TSThread, UnsafeMutablePointer<ObjCBool>) -> Void) {
        anyEnumerate(transaction: transaction, batched: false, block: block)
    }

    // Traverses all records.
    // Records are not visited in any particular order.
    class func anyEnumerate(transaction: SDSAnyReadTransaction,
                            batched: Bool = false,
                            block: @escaping (TSThread, UnsafeMutablePointer<ObjCBool>) -> Void) {
        let batchSize = batched ? Batching.kDefaultBatchSize : 0
        anyEnumerate(transaction: transaction, batchSize: batchSize, block: block)
    }

    // Traverses all records.
    // Records are not visited in any particular order.
    //
    // If batchSize > 0, the enumeration is performed in autoreleased batches.
    class func anyEnumerate(transaction: SDSAnyReadTransaction,
                            batchSize: UInt,
                            block: @escaping (TSThread, UnsafeMutablePointer<ObjCBool>) -> Void) {
        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            TSThread.ydb_enumerateCollectionObjects(with: ydbTransaction) { (object, stop) in
                guard let value = object as? TSThread else {
                    owsFailDebug("unexpected object: \(type(of: object))")
                    return
                }
                block(value, stop)
            }
        case .grdbRead(let grdbTransaction):
            do {
                let cursor = TSThread.grdbFetchCursor(transaction: grdbTransaction)
                try Batching.loop(batchSize: batchSize,
                                  loopBlock: { stop in
                                      guard let value = try cursor.next() else {
                                        stop.pointee = true
                                        return
                                      }
                                      block(value, stop)
                })
            } catch let error {
                owsFailDebug("Couldn't fetch models: \(error)")
            }
        }
    }

    // Traverses all records' unique ids.
    // Records are not visited in any particular order.
    class func anyEnumerateUniqueIds(transaction: SDSAnyReadTransaction,
                                     block: @escaping (String, UnsafeMutablePointer<ObjCBool>) -> Void) {
        anyEnumerateUniqueIds(transaction: transaction, batched: false, block: block)
    }

    // Traverses all records' unique ids.
    // Records are not visited in any particular order.
    class func anyEnumerateUniqueIds(transaction: SDSAnyReadTransaction,
                                     batched: Bool = false,
                                     block: @escaping (String, UnsafeMutablePointer<ObjCBool>) -> Void) {
        let batchSize = batched ? Batching.kDefaultBatchSize : 0
        anyEnumerateUniqueIds(transaction: transaction, batchSize: batchSize, block: block)
    }

    // Traverses all records' unique ids.
    // Records are not visited in any particular order.
    //
    // If batchSize > 0, the enumeration is performed in autoreleased batches.
    class func anyEnumerateUniqueIds(transaction: SDSAnyReadTransaction,
                                     batchSize: UInt,
                                     block: @escaping (String, UnsafeMutablePointer<ObjCBool>) -> Void) {
        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            ydbTransaction.enumerateKeys(inCollection: TSThread.collection()) { (uniqueId, stop) in
                block(uniqueId, stop)
            }
        case .grdbRead(let grdbTransaction):
            grdbEnumerateUniqueIds(transaction: grdbTransaction,
                                   sql: """
                    SELECT \(threadColumn: .uniqueId)
                    FROM \(ThreadRecord.databaseTableName)
                """,
                batchSize: batchSize,
                block: block)
        }
    }

    // Does not order the results.
    class func anyFetchAll(transaction: SDSAnyReadTransaction) -> [TSThread] {
        var result = [TSThread]()
        anyEnumerate(transaction: transaction) { (model, _) in
            result.append(model)
        }
        return result
    }

    // Does not order the results.
    class func anyAllUniqueIds(transaction: SDSAnyReadTransaction) -> [String] {
        var result = [String]()
        anyEnumerateUniqueIds(transaction: transaction) { (uniqueId, _) in
            result.append(uniqueId)
        }
        return result
    }

    class func anyCount(transaction: SDSAnyReadTransaction) -> UInt {
        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            return ydbTransaction.numberOfKeys(inCollection: TSThread.collection())
        case .grdbRead(let grdbTransaction):
            return ThreadRecord.ows_fetchCount(grdbTransaction.database)
        }
    }

    // WARNING: Do not use this method for any models which do cleanup
    //          in their anyWillRemove(), anyDidRemove() methods.
    class func anyRemoveAllWithoutInstantation(transaction: SDSAnyWriteTransaction) {
        switch transaction.writeTransaction {
        case .yapWrite(let ydbTransaction):
            ydbTransaction.removeAllObjects(inCollection: TSThread.collection())
        case .grdbWrite(let grdbTransaction):
            do {
                try ThreadRecord.deleteAll(grdbTransaction.database)
            } catch {
                owsFailDebug("deleteAll() failed: \(error)")
            }
        }

        if shouldBeIndexedForFTS {
            FullTextSearchFinder.allModelsWereRemoved(collection: collection(), transaction: transaction)
        }
    }

    class func anyRemoveAllWithInstantation(transaction: SDSAnyWriteTransaction) {
        // To avoid mutationDuringEnumerationException, we need
        // to remove the instances outside the enumeration.
        let uniqueIds = anyAllUniqueIds(transaction: transaction)

        var index: Int = 0
        do {
            try Batching.loop(batchSize: Batching.kDefaultBatchSize,
                              loopBlock: { stop in
                                  guard index < uniqueIds.count else {
                                    stop.pointee = true
                                    return
                                  }
                                  let uniqueId = uniqueIds[index]
                                  index = index + 1
                                  guard let instance = anyFetch(uniqueId: uniqueId, transaction: transaction) else {
                                      owsFailDebug("Missing instance.")
                                      return
                                  }
                                  instance.anyRemove(transaction: transaction)
            })
        } catch {
            owsFailDebug("Error: \(error)")
        }

        if shouldBeIndexedForFTS {
            FullTextSearchFinder.allModelsWereRemoved(collection: collection(), transaction: transaction)
        }
    }

    class func anyExists(uniqueId: String,
                        transaction: SDSAnyReadTransaction) -> Bool {
        assert(uniqueId.count > 0)

        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            return ydbTransaction.hasObject(forKey: uniqueId, inCollection: TSThread.collection())
        case .grdbRead(let grdbTransaction):
            let sql = "SELECT EXISTS ( SELECT 1 FROM \(ThreadRecord.databaseTableName) WHERE \(threadColumn: .uniqueId) = ? )"
            let arguments: StatementArguments = [uniqueId]
            return try! Bool.fetchOne(grdbTransaction.database, sql: sql, arguments: arguments) ?? false
        }
    }
}

// MARK: - Swift Fetch

public extension TSThread {
    class func grdbFetchCursor(sql: String,
                               arguments: StatementArguments = StatementArguments(),
                               transaction: GRDBReadTransaction) -> TSThreadCursor {
        do {
            let sqlRequest = SQLRequest<Void>(sql: sql, arguments: arguments, cached: true)
            let cursor = try ThreadRecord.fetchCursor(transaction.database, sqlRequest)
            return TSThreadCursor(cursor: cursor)
        } catch {
            Logger.error("sql: \(sql)")
            owsFailDebug("Read failed: \(error)")
            return TSThreadCursor(cursor: nil)
        }
    }

    class func grdbFetchOne(sql: String,
                            arguments: StatementArguments = StatementArguments(),
                            transaction: GRDBReadTransaction) -> TSThread? {
        assert(sql.count > 0)

        do {
            let sqlRequest = SQLRequest<Void>(sql: sql, arguments: arguments, cached: true)
            guard let record = try ThreadRecord.fetchOne(transaction.database, sqlRequest) else {
                return nil
            }

            return try TSThread.fromRecord(record)
        } catch {
            owsFailDebug("error: \(error)")
            return nil
        }
    }
}

// MARK: - SDSSerializer

// The SDSSerializer protocol specifies how to insert and update the
// row that corresponds to this model.
class TSThreadSerializer: SDSSerializer {

    private let model: TSThread
    public required init(model: TSThread) {
        self.model = model
    }

    // MARK: - Record

    func asRecord() throws -> SDSRecord {
        let id: Int64? = model.grdbId?.int64Value

        let recordType: SDSRecordType = .thread
        let uniqueId: String = model.uniqueId

        // Properties
        let conversationColorName: String = model.conversationColorName.rawValue
        let creationDate: Double? = archiveOptionalDate(model.creationDate)
        let isArchived: Bool = model.isArchived
        let lastInteractionRowId: Int64 = model.lastInteractionRowId
        let messageDraft: String? = model.messageDraft
        let mutedUntilDate: Double? = archiveOptionalDate(model.mutedUntilDate)
        let shouldThreadBeVisible: Bool = model.shouldThreadBeVisible
        let contactPhoneNumber: String? = nil
        let contactUUID: String? = nil
        let groupModel: Data? = nil
        let hasDismissedOffers: Bool? = nil

        return ThreadRecord(delegate: model, id: id, recordType: recordType, uniqueId: uniqueId, conversationColorName: conversationColorName, creationDate: creationDate, isArchived: isArchived, lastInteractionRowId: lastInteractionRowId, messageDraft: messageDraft, mutedUntilDate: mutedUntilDate, shouldThreadBeVisible: shouldThreadBeVisible, contactPhoneNumber: contactPhoneNumber, contactUUID: contactUUID, groupModel: groupModel, hasDismissedOffers: hasDismissedOffers)
    }
}

//
//  DatabaseManager.swift
//  Quota
//
//  Created by Marcin Włoczko on 02/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import Foundation
import CoreData

typealias SuccessCompletion = (Bool) -> Void

protocol DatabaseType {
    func saveGroup(_ group: Group)
    func saveMember(_ member: Member, for groupMO: GroupManagedObject)
    func saveExpense(_ expense: Expense, for group: Group)
    func saveExchangeRate(_ exchangeRate: ExchangeRate, for member: Member)
    func updateMember(_ member: Member)
    func fetch<T: NSManagedObject>() -> [T]?
}

final class DatabaseManager: DatabaseType {

    //MARK:- Constants

    static let shared = DatabaseManager()

    //MARK:- Variables

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Quota")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    //MARK:- Initializers

    private init() {}

    //MARK:- Main

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func saveGroup(_ group: Group) {
        let context = persistentContainer.viewContext
        let groupMO = GroupManagedObject(context: context)
        groupMO.id = Int64(group.id)
        groupMO.currencyCode = group.currency.code
        groupMO.name = group.name
        group.members.forEach{ saveMember($0, for: groupMO) }
        saveContext()
    }

    func saveMember(_ member: Member, for groupMO: GroupManagedObject) {
        let context = persistentContainer.viewContext
        let memberMO = MemberManagedObject(context: context)
        memberMO.id = Int64(member.id)
        memberMO.name = member.name
        memberMO.surname = member.surname
        memberMO.email = member.email
        memberMO.totalBalance = member.totalBalance
        groupMO.addToMembers(memberMO)
        saveContext()
    }

    func saveExpense(_ expense: Expense, for group: Group) {
        let context = persistentContainer.viewContext
        let expenseMO = ExpenseManagedObject(context: context)
        expenseMO.amount = expense.amount
        expenseMO.currencyCode = expense.currency.code
        expenseMO.expenseDescription = expense.description
        expenseMO.date = expense.date
        let tip = expense.tip != nil ? NSNumber(value: expense.tip!) : nil
        expenseMO.tip = tip
        expense.contributions.forEach{ saveContribution($0, for: expenseMO) }
        expense.items.forEach { saveItem($0, for: expenseMO) }
        if let payerMO = fetchMemberMO(with: expense.payer.id) {
            expenseMO.payer = payerMO
        }
        for borrower in expense.borrowers {
            if let borrowerMO = fetchMemberMO(with: borrower.id) {
                expenseMO.addToBorrowers(borrowerMO)
            }
        }
        if let group = fetchGroupMO(with: group.id) {
            group.addToExpenses(expenseMO)
            expenseMO.group = group
        }
        saveContext()
    }

    func saveContribution(_ contribution: Contribution,
                          for expenseMO: ExpenseManagedObject) {
        let context = persistentContainer.viewContext
        let contributionMO = ContributionManagedObject(context: context)
        if let memberMO = fetchMemberMO(with: contribution.member.id) {
            contributionMO.member = memberMO
        }
        contributionMO.value = contribution.value
        expenseMO.addToContributions(contributionMO)
    }

    func saveItem(_ item: BillItem, for expenseMO: ExpenseManagedObject) {
        let context = persistentContainer.viewContext
        let itemMO = BillItemManagedObject(context: context)
        itemMO.amount = item.amount
        itemMO.info = item.description
        itemMO.expense = expenseMO
        expenseMO.addToItems(itemMO)
    }

    func saveExchangeRate(_ exchangeRate: ExchangeRate, for member: Member) {
        let context = persistentContainer.viewContext
        let exchangeRateMO = ExchangeRateManagedObject(context: context)
        if let memberMO = fetchMemberMO(with: member.id) {
            memberMO.addToExchangeRates(exchangeRateMO)
            exchangeRateMO.member = memberMO
        }
        exchangeRateMO.rate = exchangeRate.rate
        exchangeRateMO.orderedCurrencyCode = exchangeRate.orderedCurrency.code
        exchangeRateMO.ownedCurrencyCode = exchangeRate.ownedCurrency.code
        saveContext()
    }

    func updateMember(_ member: Member) {
        if let oldMember = fetchMemberMO(with: member.id) {
            oldMember.totalBalance = member.totalBalance
        }
        saveContext()
    }

    func fetch<T: NSManagedObject>() -> [T]? {
        let context = persistentContainer.viewContext
        var result: [T]?
        do {
            let data = try context.fetch(T.fetchRequest())
            result = data as? [T]
        } catch {
            fatalError("Unable to fetch \(T.self)")
        }
        return result
    }

    private func fetchGroupMO(with id: Int) -> GroupManagedObject? {
        guard let groups: [GroupManagedObject] = fetch() else { return nil }
        return groups.first { $0.id == id }
    }

    private func fetchMemberMO(with id: Int) -> MemberManagedObject? {
        guard let members: [MemberManagedObject] = fetch() else { return nil }
        return members.first { $0.id == id }
    }

//    func deleteProjectDTO(with id: Int) {
//        let context = persistentContainer.viewContext
//        do {
//            let projects = try context.fetch(ProjectDTO.fetchRequest()) as! [ProjectDTO]
//            guard let project = projects.first(where: { $0.id == id }) else { return }
//            context.delete(project)
//        } catch {
//            fatalError("Unable to fetach projects")
//        }
//        saveContext()
//    }
}


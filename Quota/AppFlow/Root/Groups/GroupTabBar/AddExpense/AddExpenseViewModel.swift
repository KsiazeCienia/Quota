//
//  AddExpenseViewModel.swift
//  Quota
//
//  Created by Marcin Włoczko on 27/11/2018.
//  Copyright © 2018 Marcin Włoczko. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct ExpenseViewDescription {
    let description: String
    let amount: String
    let tip: String?
}

protocol AddExpenseViewModelDelegate: class {
    func addExpenseViewModelDidRequestPayer(_ viewModel: AddExpenseViewModel,
                                            currentPayer: Member?)
    func addExpenseViewModelDidRequestBorrowers(_ viewModel: AddExpenseViewModel,
                                                currentBorrowers: [Member])
    func addExpenseViewModelDidRequestSplit(_ viewModel: AddExpenseViewModel,
                                            with borrowers: [Member],
                                            amount: Double)
    func addExpenseViewModelDidRequestSplit(_ viewModel: AddExpenseViewModel,
                                            with contributions: [Contribution],
                                            amount: Double)
    func addExpenseViewModelDidRequestDismiss()
    func addExpenseViewModel(didCreate expense: Expense)
    func addExpenseViewModelDidRequestBillFlow(with items: [BillItem]?)
    func addExpenseViewModel(didFailWith errorMessage: String)
}

protocol AddExpenseViewModel: SelectableListViewModelDelegate, SplitViewModelDelegate {

    var delegate: AddExpenseViewModelDelegate? { get set }

    var currencyTextFiledViewModel: CurrencyTextFieldViewModel { get }
    var dateTextFieldViewModel: DateTextFieldViewModel { get }
    var expenseViewDescription: ExpenseViewDescription? { get }
    var descriptionPlaceholder: String { get }
    var amountPlaceholder: String { get }
    var tipPlaceholder: String { get }
    var payerTitle: String { get }
    var borrowersTitle: String { get }
    var splitTitle: String { get }
    var dissmisAsset: String { get }
    var saveTitle: String { get }

    var payerAction: PublishRelay<Void> { get }
    var borrowersAction: PublishRelay<Void> { get }
    var splitAction: PublishRelay<Void> { get }
    var cancelAction: PublishRelay<Void> { get }
    var billAction: PublishRelay<Void> { get }
    var saveAction: PublishRelay<Void> { get }
    var updateAmount: PublishRelay<String> { get }
    var description: BehaviorRelay<String?> { get }
    var amount: BehaviorRelay<String?> { get }
    var tip: BehaviorRelay<String?> { get }
    var currency: BehaviorRelay<Currency?> { get }
    var isSplitEnable: BehaviorRelay<Bool> { get }
    var errorAction: PublishRelay<String> { get }
    var billAsset: BehaviorRelay<String> { get }

    func addItems(_ items: [BillItem])
    func saveExpense(with rate: Double)
}

final class AddExpenseViewModelImp: AddExpenseViewModel {

    // MARK: - View's components

    let descriptionPlaceholder: String = "description".localized
    let amountPlaceholder: String = "amount".localized
    let tipPlaceholder: String = "tip".localized
    let payerTitle: String = "payer".localized
    let borrowersTitle: String = "borrowers".localized
    let splitTitle: String = "split_method".localized
    let dissmisAsset: String = "dismiss"
    let saveTitle: String = "save".localized
    let currencyTextFiledViewModel: CurrencyTextFieldViewModel
    let dateTextFieldViewModel: DateTextFieldViewModel
    let expenseViewDescription: ExpenseViewDescription?

    // MARK: - Observers

    let billAsset = BehaviorRelay<String>(value: "scaner")
    let payerAction = PublishRelay<Void>()
    let borrowersAction = PublishRelay<Void>()
    let splitAction = PublishRelay<Void>()
    let saveAction = PublishRelay<Void>()
    let cancelAction = PublishRelay<Void>()
    let billAction = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    let description = BehaviorRelay<String?>(value: nil)
    let tip: BehaviorRelay<String?>
    let amount: BehaviorRelay<String?>
    let updateAmount = PublishRelay<String>()
    let currency = BehaviorRelay<Currency?>(value: nil)
    let isSplitEnable = BehaviorRelay<Bool>(value: false)
    let errorAction = PublishRelay<String>()

    // MARK: - Variables

    private var payer: Member?
    private var borrowers: [Member]
    private var contributions: [Contribution] = []
    private var items: [BillItem] = []
    private let group: Group
    private var expense: Expense?
    private let shouldBeRemoved: Bool
    private let expenseCalculator: ExpensesCalculator

    // MARK: - Delegate

    weak var delegate: AddExpenseViewModelDelegate?

    // MARK: - Initializer

    init(currencyTextFiledViewModel: CurrencyTextFieldViewModel,
         dateTextFieldViewModel: DateTextFieldViewModel,
         expenseCalculator: ExpensesCalculator, group: Group) {
        self.currencyTextFiledViewModel = currencyTextFiledViewModel
        self.dateTextFieldViewModel = dateTextFieldViewModel
        self.expenseCalculator = expenseCalculator
        self.group = group
        self.borrowers = group.members
        self.tip = BehaviorRelay<String?>(value: nil)
        self.amount = BehaviorRelay<String?>(value: nil)
        self.expenseViewDescription = nil
        shouldBeRemoved = false
        setupBinding()
    }

    init(currencyTextFiledViewModel: CurrencyTextFieldViewModel,
         dateTextFieldViewModel: DateTextFieldViewModel,
         expenseCalculator: ExpensesCalculator, group: Group, expense: Expense) {
        self.currencyTextFiledViewModel = currencyTextFiledViewModel
        self.dateTextFieldViewModel = dateTextFieldViewModel
        self.expenseCalculator = expenseCalculator
        self.group = group
        self.payer = expense.payer
        self.borrowers = expense.borrowers
        let tipString = expense.tip != nil ? String(expense.tip!) : nil
        self.expenseViewDescription = ExpenseViewDescription(description: expense.description,
                                                             amount: String(expense.amount),
                                                             tip: tipString)
        shouldBeRemoved = true
        self.tip = BehaviorRelay<String?>(value: tipString)
        self.amount = BehaviorRelay<String?>(value: String(expense.amount))
        setupBinding()
    }

    func addItems(_ items: [BillItem]) {
        self.items = items
        let totalAmount = items.map { $0.amount }.reduce(0, { $0 + $1 })
        billAsset.accept("paragon")
        updateAmount.accept(String(format: "%.2f", totalAmount))
    }

    func splitVIewModel(didFailWith errorMessage: String) {
        delegate?.addExpenseViewModel(didFailWith: errorMessage)
    }

    private func prepareToShowSplit() {
        guard let amount = amount.value.commaToDecimal(),
            !borrowers.isEmpty else { return }
        if contributions.isEmpty {
            delegate?.addExpenseViewModelDidRequestSplit(self,
                                                         with: borrowers,
                                                         amount: amount)
        } else {
            delegate?.addExpenseViewModelDidRequestSplit(self,
                                                         with: contributions,
                                                         amount: amount)
        }
    }

    private func saveExpense(expense: Expense) {
        expenseCalculator.updateBalances(for: group, with: expense)
        DatabaseManager.shared.saveExpense(expense, for: group)
    }

    private func dismiss(with expense: Expense) {
        delegate?.addExpenseViewModel(didCreate: expense)
    }

    func saveExpense(with rate: Double) {
        guard let expense = expense else { return }
        let updateExpense = expenseCalculator.normaliceExpense(expense,
                                           to: group.currency,
                                           with: rate)
        saveExpense(expense: updateExpense)
        dismiss(with: expense)
    }

    private func handelSaveExpenseRequest() {
        guard let expense = createExpenseIfPossible() else {
            return
        }
        if group.currency.code != expense.currency.code {
            expenseCalculator
                .normalizeExpense(expense, to: group.currency) { [weak self] result in
                    switch result {
                    case .Error(error: _):
                        self?.errorAction.accept("error_message".localized)
                    case .Success(result: let normalizeExpense):
                        self?.saveExpense(expense: normalizeExpense)
                        self?.dismiss(with: expense)
                    }
                }
        } else {
            saveExpense(expense: expense)
            dismiss(with: expense)
        }

    }

    private func createExpenseIfPossible() -> Expense? {
        guard let description = description.value,
            let amount = amount.value.commaToDecimal()?.rounded(toPlaces: 2),
            let currency = currency.value,
            let date = dateTextFieldViewModel.date.value else {
                delegate?.addExpenseViewModel(didFailWith: "empty_fields_message".localized)
                return nil
        }

        guard let payer = payer,
            !borrowers.isEmpty else {
                delegate?.addExpenseViewModel(didFailWith: "members_not_selected".localized)
                return nil
        }

        if contributions.isEmpty {
            createContributors()
        }

        let tipValue = tip.value.commaToDecimal()

        if let tipValue = tip.value.commaToDecimal() {
            contributions = add(tip: tipValue, to: contributions)
        }

        let expense = Expense(description: description, amount: amount,
                          tip: tipValue, date: date, currency: currency,
                          payer: payer, borrowers: borrowers,
                          contributions: contributions, items: items)

        self.expense = expense
        return expense
    }

    private func add(tip: Double, to contributions: [Contribution]) -> [Contribution] {
        let totalAmount = contributions.map { $0.value }.reduce(0, { $0 + $1 })
        for contribution in contributions {
            let proportion = contribution.value / totalAmount
            contribution.value += tip * proportion
        }
        return contributions
    }

    private func createContributors() {
        guard let amount = amount.value.commaToDecimal(),
            !borrowers.isEmpty else { return }
        contributions = borrowers.map { Contribution(member: $0,
                                                     value: amount / Double(borrowers.count)) }
    }

    // MARK: - Setup

    private func setupBinding() {
        payerAction.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.delegate?.addExpenseViewModelDidRequestPayer(self,
                                                              currentPayer: self.payer)
        }).disposed(by: disposeBag)

        borrowersAction.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.delegate?.addExpenseViewModelDidRequestBorrowers(self,
                                                                  currentBorrowers: self.borrowers)
        }).disposed(by: disposeBag)

        cancelAction.subscribe(onNext: { [weak self] in
            self?.delegate?.addExpenseViewModelDidRequestDismiss()
        }).disposed(by: disposeBag)

        splitAction.subscribe(onNext: { [weak self] in
           self?.prepareToShowSplit()
        }).disposed(by: disposeBag)

        currencyTextFiledViewModel.selectedCurrency
            .bind(to: currency)
            .disposed(by: disposeBag)

        saveAction.subscribe(onNext: { [weak self] in
            self?.handelSaveExpenseRequest()
        }).disposed(by: disposeBag)

        amount.map { $0 != "" }.subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            self.isSplitEnable.accept(value&&(!self.borrowers.isEmpty))
        }).disposed(by: disposeBag)

        billAction.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            let items = self.items.isEmpty ? nil : self.items
            self.delegate?.addExpenseViewModelDidRequestBillFlow(with: items)
        }).disposed(by: disposeBag)
    }

    // MARK: - Selectable

    func selectableListViewModel(_ viewModel: SelectableListViewModel, members: [Member]) {
        switch viewModel {
        case _ as PayerViewModel:
            guard let payer = members.first else { return }
            self.payer = payer
        case _ as BorrowersViewModel:
            borrowers = members
            isSplitEnable.accept(true)
        default:
            break
        }
    }

    // MARK: - SplitViewModelDelegate

    func splitViewModele(didCreate contributions: [Contribution]) {
        self.contributions = contributions
    }
}

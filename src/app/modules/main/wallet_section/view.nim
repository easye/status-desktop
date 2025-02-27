import NimQml, json

import ./activity/controller as activityc
import ./collectibles/controller as collectiblesc
import ./collectible_details/controller as collectible_detailsc
import ./io_interface
import ../../shared_models/currency_amount

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      totalCurrencyBalance: CurrencyAmount
      signingPhrase: string
      isMnemonicBackedUp: bool
      tmpAmount: float  # shouldn't be used anywhere except in prepare*/getPrepared* procs
      tmpSymbol: string # shouldn't be used anywhere except in prepare*/getPrepared* procs
      activityController: activityc.Controller
      tmpActivityController: activityc.Controller
      collectiblesController: collectiblesc.Controller
      collectibleDetailsController: collectible_detailsc.Controller
      isNonArchivalNode: bool

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface, activityController: activityc.Controller, tmpActivityController: activityc.Controller, collectiblesController: collectiblesc.Controller, collectibleDetailsController: collectible_detailsc.Controller): View =
    new(result, delete)
    result.delegate = delegate
    result.activityController = activityController
    result.tmpActivityController = tmpActivityController
    result.collectiblesController = collectiblesController
    result.collectibleDetailsController = collectibleDetailsController
    result.setup()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc updateCurrency*(self: View, currency: string) {.slot.} =
    self.delegate.updateCurrency(currency)
  proc getCurrentCurrency(self: View): string {.slot.} =
    return self.delegate.getCurrentCurrency()
  QtProperty[string] currentCurrency:
    read = getCurrentCurrency

  proc filterChanged*(self: View, addresses: string, includeWatchOnly: bool, allAddresses: bool)  {.signal.}

  proc totalCurrencyBalanceChanged*(self: View) {.signal.}

  proc getTotalCurrencyBalance(self: View): QVariant {.slot.} =
    return newQVariant(self.totalCurrencyBalance)

  QtProperty[QVariant] totalCurrencyBalance:
    read = getTotalCurrencyBalance
    notify = totalCurrencyBalanceChanged

  proc getSigningPhrase(self: View): QVariant {.slot.} =
    return newQVariant(self.signingPhrase)

  QtProperty[QVariant] signingPhrase:
    read = getSigningPhrase

  proc getIsMnemonicBackedUp(self: View): QVariant {.slot.} =
    return newQVariant(self.isMnemonicBackedUp)

  QtProperty[QVariant] isMnemonicBackedUp:
    read = getIsMnemonicBackedUp

  proc setFilterAddress(self: View, address: string) {.slot.} =
    self.delegate.setFilterAddress(address)

  proc setFillterAllAddresses(self: View) {.slot.} =
    self.delegate.setFillterAllAddresses()

  proc toggleWatchOnlyAccounts(self: View) {.slot.} =
    self.delegate.toggleWatchOnlyAccounts()

  proc setTotalCurrencyBalance*(self: View, totalCurrencyBalance: CurrencyAmount) =
    self.totalCurrencyBalance = totalCurrencyBalance
    self.totalCurrencyBalanceChanged()

# Returning a QVariant from a slot with parameters other than "self" won't compile
#  proc getCurrencyAmount*(self: View, amount: float, symbol: string): QVariant {.slot.} =
#    return newQVariant(self.delegate.getCurrencyAmount(amount, symbol))

# As a workaround, we do it in two steps: First call prepareCurrencyAmount, then getPreparedCurrencyAmount
  proc prepareCurrencyAmount*(self: View, amount: float, symbol: string) {.slot.} =
    self.tmpAmount = amount
    self.tmpSymbol = symbol

  proc getPreparedCurrencyAmount*(self: View): QVariant {.slot.} =
    let currencyAmount = self.delegate.getCurrencyAmount(self.tmpAmount, self.tmpSymbol)
    self.tmpAmount = 0
    self.tmpSymbol = "ERROR"
    return newQVariant(currencyAmount)

  proc setData*(self: View, signingPhrase: string, mnemonicBackedUp: bool) =
    self.signingPhrase = signingPhrase
    self.isMnemonicBackedUp = mnemonicBackedUp

  proc runAddAccountPopup*(self: View, addingWatchOnlyAccount: bool) {.slot.} =
    self.delegate.runAddAccountPopup(addingWatchOnlyAccount)

  proc runEditAccountPopup*(self: View, address: string) {.slot.} =
    self.delegate.runEditAccountPopup(address)

  proc getAddAccountModule(self: View): QVariant {.slot.} =
    return self.delegate.getAddAccountModule()
  QtProperty[QVariant] addAccountModule:
    read = getAddAccountModule

  proc displayAddAccountPopup*(self: View) {.signal.}
  proc emitDisplayAddAccountPopup*(self: View) =
    self.displayAddAccountPopup()

  proc destroyAddAccountPopup*(self: View) {.signal.}
  proc emitDestroyAddAccountPopup*(self: View) =
    self.destroyAddAccountPopup()

  proc walletAccountRemoved*(self: View, address: string) {.signal.}
  proc emitWalletAccountRemoved*(self: View, address: string) =
    self.walletAccountRemoved(address)

  proc getActivityController(self: View): QVariant {.slot.} =
    return newQVariant(self.activityController)
  QtProperty[QVariant] activityController:
    read = getActivityController

  proc getCollectiblesController(self: View): QVariant {.slot.} =
    return newQVariant(self.collectiblesController)
  QtProperty[QVariant] collectiblesController:
    read = getCollectiblesController

  proc getCollectibleDetailsController(self: View): QVariant {.slot.} =
    return newQVariant(self.collectibleDetailsController)
  QtProperty[QVariant] collectibleDetailsController:
    read = getCollectibleDetailsController

  proc getTmpActivityController(self: View): QVariant {.slot.} =
    return newQVariant(self.tmpActivityController)
  QtProperty[QVariant] tmpActivityController:
    read = getTmpActivityController

  proc getChainIdForChat*(self: View): int {.slot.} =
    return self.delegate.getChainIdForChat()

  proc getLatestBlockNumber*(self: View, chainId: int): string {.slot.} =
    return self.delegate.getLatestBlockNumber(chainId)

  proc fetchDecodedTxData*(self: View, txHash: string, data: string) {.slot.}   =
    self.delegate.fetchDecodedTxData(txHash, data)

  proc getIsNonArchivalNode(self: View): bool {.slot.} =
    return self.isNonArchivalNode

  proc isNonArchivalNodeChanged(self: View) {.signal.}

  proc setIsNonArchivalNode*(self: View, isNonArchivalNode: bool) =
    self.isNonArchivalNode = isNonArchivalNode
    self.isNonArchivalNodeChanged()

  QtProperty[bool] isNonArchivalNode:
    read = getIsNonArchivalNode
    notify = isNonArchivalNodeChanged

  proc txDecoded*(self: View, txHash: string, dataDecoded: string) {.signal.}

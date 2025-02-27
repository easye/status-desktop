import NimQml, Tables, strformat, sequtils, stint
import token_item
import token_owners_item
import token_owners_model
import ../../../../../../app_service/service/community_tokens/dto/community_token
import ../../../../../../app_service/common/utils
import ../../../../../../app_service/common/types
from backend/collectibles_types import CollectibleOwner

type
  ModelRole {.pure.} = enum
    ContractUniqueKey = UserRole + 1
    TokenType
    TokenAddress
    Name
    Symbol
    Description
    Supply
    InfiniteSupply
    Transferable
    RemoteSelfDestruct
    ChainId
    DeployState
    Image
    ChainName
    ChainIcon
    TokenOwnersModel
    AccountName
    RemainingSupply
    Decimals
    BurnState
    RemotelyDestructState

QtObject:
  type TokenModel* = ref object of QAbstractListModel
    items*: seq[TokenItem]

  proc setup(self: TokenModel) =
    self.QAbstractListModel.setup

  proc delete(self: TokenModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc newTokenModel*(): TokenModel =
    new(result, delete)
    result.setup

  proc updateDeployState*(self: TokenModel, chainId: int, contractAddress: string, deployState: DeployState) =
    for i in 0 ..< self.items.len:
      if((self.items[i].tokenDto.address == contractAddress) and (self.items[i].tokenDto.chainId == chainId)):
        self.items[i].tokenDto.deployState = deployState
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.dataChanged(index, index, @[ModelRole.DeployState.int])
        return

  proc updateBurnState*(self: TokenModel, chainId: int, contractAddress: string, burnState: ContractTransactionStatus) =
    for i in 0 ..< self.items.len:
      if((self.items[i].tokenDto.address == contractAddress) and (self.items[i].tokenDto.chainId == chainId)):
        self.items[i].burnState = burnState
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.dataChanged(index, index, @[ModelRole.BurnState.int])
        return

  proc updateRemoteDestructedAddresses*(self: TokenModel, chainId: int, contractAddress: string, remoteDestructedAddresses: seq[string]) =
    for i in 0 ..< self.items.len:
      if((self.items[i].tokenDto.address == contractAddress) and (self.items[i].tokenDto.chainId == chainId)):
        self.items[i].remoteDestructedAddresses = remoteDestructedAddresses
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.dataChanged(index, index, @[ModelRole.RemotelyDestructState.int])
        self.items[i].tokenOwnersModel.updateRemoteDestructState(remoteDestructedAddresses)
        self.dataChanged(index, index, @[ModelRole.TokenOwnersModel.int])
        return

  proc updateSupply*(self: TokenModel, chainId: int, contractAddress: string, supply: Uint256, destructedAmount: Uint256) =
    for i in 0 ..< self.items.len:
      if((self.items[i].tokenDto.address == contractAddress) and (self.items[i].tokenDto.chainId == chainId)):
        if self.items[i].tokenDto.supply != supply or self.items[i].destructedAmount != destructedAmount:
          self.items[i].tokenDto.supply = supply
          self.items[i].destructedAmount = destructedAmount
          let index = self.createIndex(i, 0, nil)
          defer: index.delete
          self.dataChanged(index, index, @[ModelRole.Supply.int])
        return

  proc updateRemainingSupply*(self: TokenModel, chainId: int, contractAddress: string, remainingSupply: Uint256) =
    for i in 0 ..< self.items.len:
      if((self.items[i].tokenDto.address == contractAddress) and (self.items[i].tokenDto.chainId == chainId)):
        if self.items[i].remainingSupply != remainingSupply:
          self.items[i].remainingSupply = remainingSupply
          let index = self.createIndex(i, 0, nil)
          defer: index.delete
          self.dataChanged(index, index, @[ModelRole.RemainingSupply.int])
        return

  proc setCommunityTokenOwners*(self: TokenModel, chainId: int, contractAddress: string, owners: seq[CollectibleOwner]) =
    for i in 0 ..< self.items.len:
      if((self.items[i].tokenDto.address == contractAddress) and (self.items[i].tokenDto.chainId == chainId)):
        self.items[i].tokenOwnersModel.setItems(owners.map(proc(owner: CollectibleOwner): TokenOwnersItem =
          # TODO find member with the address - later when airdrop to member will be added
          result = initTokenOwnersItem("", "", owner, self.items[i].remoteDestructedAddresses)
        ))
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.dataChanged(index, index, @[ModelRole.TokenOwnersModel.int])
        return

  proc countChanged(self: TokenModel) {.signal.}

  proc setItems*(self: TokenModel, items: seq[TokenItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc appendItem*(self: TokenModel, item: TokenItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()
    self.countChanged()

  proc removeItemByChainIdAndAddress*(self: TokenModel, chainId: int, address: string) =
    for i in 0 ..< self.items.len:
      if((self.items[i].tokenDto.address == address) and (self.items[i].tokenDto.chainId == chainId)):
        let parentModelIndex = newQModelIndex()
        defer: parentModelIndex.delete

        self.beginRemoveRows(parentModelIndex, i, i)
        self.items.delete(i)
        self.endRemoveRows()
        self.countChanged()
        return

  proc getCount*(self: TokenModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: TokenModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: TokenModel): Table[int, string] =
    {
      ModelRole.ContractUniqueKey.int:"contractUniqueKey",
      ModelRole.TokenType.int:"tokenType",
      ModelRole.TokenAddress.int:"tokenAddress",
      ModelRole.Name.int:"name",
      ModelRole.Symbol.int:"symbol",
      ModelRole.Description.int:"description",
      ModelRole.Supply.int:"supply",
      ModelRole.InfiniteSupply.int:"infiniteSupply",
      ModelRole.Transferable.int:"transferable",
      ModelRole.RemoteSelfDestruct.int:"remoteSelfDestruct",
      ModelRole.ChainId.int:"chainId",
      ModelRole.DeployState.int:"deployState",
      ModelRole.Image.int:"image",
      ModelRole.ChainName.int:"chainName",
      ModelRole.ChainIcon.int:"chainIcon",
      ModelRole.TokenOwnersModel.int:"tokenOwnersModel",
      ModelRole.AccountName.int:"accountName",
      ModelRole.RemainingSupply.int:"remainingSupply",
      ModelRole.Decimals.int:"decimals",
      ModelRole.BurnState.int:"burnState",
      ModelRole.RemotelyDestructState.int:"remotelyDestructState",
    }.toTable

  method data(self: TokenModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.ContractUniqueKey:
        result = newQVariant(contractUniqueKey(item.tokenDto.chainId, item.tokenDto.address))
      of ModelRole.TokenType:
        result = newQVariant(item.tokenDto.tokenType.int)
      of ModelRole.TokenAddress:
        result = newQVariant(item.tokenDto.address)
      of ModelRole.Name:
        result = newQVariant(item.tokenDto.name)
      of ModelRole.Symbol:
        result = newQVariant(item.tokenDto.symbol)
      of ModelRole.Description:
        result = newQVariant(item.tokenDto.description)
      of ModelRole.Supply:
        # we need to present maxSupply - destructedAmount
        result = newQVariant(supplyByType(item.tokenDto.supply - item.destructedAmount, item.tokenDto.tokenType))
      of ModelRole.InfiniteSupply:
        result = newQVariant(item.tokenDto.infiniteSupply)
      of ModelRole.Transferable:
        result = newQVariant(item.tokenDto.transferable)
      of ModelRole.RemoteSelfDestruct:
        result = newQVariant(item.tokenDto.remoteSelfDestruct)
      of ModelRole.ChainId:
        result = newQVariant(item.tokenDto.chainId)
      of ModelRole.DeployState:
        result = newQVariant(item.tokenDto.deployState.int)
      of ModelRole.Image:
        result = newQVariant(item.tokenDto.image)
      of ModelRole.ChainName:
        result = newQVariant(item.chainName)
      of ModelRole.ChainIcon:
        result = newQVariant(item.chainIcon)
      of ModelRole.TokenOwnersModel:
        result = newQVariant(item.tokenOwnersModel)
      of ModelRole.AccountName:
        result = newQVariant(item.accountName)
      of ModelRole.RemainingSupply:
        result = newQVariant(supplyByType(item.remainingSupply, item.tokenDto.tokenType))
      of ModelRole.Decimals:
        result = newQVariant(item.tokenDto.decimals)
      of ModelRole.BurnState:
        result = newQVariant(item.burnState.int)
      of ModelRole.RemotelyDestructState:
        let destructStatus = if len(item.remoteDestructedAddresses) > 0: ContractTransactionStatus.InProgress.int else: ContractTransactionStatus.Completed.int
        result = newQVariant(destructStatus)

  proc `$`*(self: TokenModel): string =
      for i in 0 ..< self.items.len:
        result &= fmt"""TokenModel:
        [{i}]:({$self.items[i]})
        """
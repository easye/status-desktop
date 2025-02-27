import strformat, sequtils, stint
import ../../../../../../app_service/service/community_tokens/dto/community_token
import ../../../../../../app_service/service/network/dto
import ../../../../../../app_service/common/types
from backend/collectibles_types import CollectibleOwner

import token_owners_model
import token_owners_item

export community_token

type
  TokenItem* = object
    tokenDto*: CommunityTokenDto
    chainName*: string
    chainIcon*: string
    accountName*: string
    remainingSupply*: Uint256
    destructedAmount*: Uint256
    burnState*: ContractTransactionStatus
    remoteDestructedAddresses*: seq[string]
    tokenOwnersModel*: token_owners_model.TokenOwnersModel

proc initTokenItem*(
  tokenDto: CommunityTokenDto,
  network: NetworkDto,
  tokenOwners: seq[CollectibleOwner],
  accountName: string,
  burnState: ContractTransactionStatus,
  remoteDestructedAddresses: seq[string],
  remainingSupply: Uint256,
  destructedAmount: Uint256
): TokenItem =
  result.tokenDto = tokenDto
  if network != nil:
    result.chainName = network.chainName
    result.chainIcon = network.iconURL
  result.accountName = accountName
  result.remainingSupply = remainingSupply
  result.destructedAmount = destructedAmount
  result.burnState = burnState
  result.remoteDestructedAddresses = remoteDestructedAddresses
  result.tokenOwnersModel = newTokenOwnersModel()
  result.tokenOwnersModel.setItems(tokenOwners.map(proc(owner: CollectibleOwner): TokenOwnersItem =
          # TODO find member with the address - later when airdrop to member will be added
          result = initTokenOwnersItem("", "", owner, remoteDestructedAddresses)
        ))

proc `$`*(self: TokenItem): string =
  result = fmt"""TokenItem(
    tokenDto: {self.tokenDto},
    chainName: {self.chainName},
    chainIcon: {self.chainIcon},
    remainingSupply: {self.remainingSupply},
    destructedAmount: {self.destructedAmount},
    burnState: {self.burnState},
    tokenOwnersModel: {self.tokenOwnersModel},
    remoteDestructedAddresses: {self.remoteDestructedAddresses}
    ]"""


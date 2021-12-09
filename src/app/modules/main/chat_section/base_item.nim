type 
  BaseItem* {.pure inheritable.} = ref object of RootObj
    id: string
    name: string
    `type`: int
    icon: string
    isIdenticon: bool
    color: string
    description: string
    hasUnreadMessages: bool
    notificationsCount: int
    muted: bool
    active: bool
    position: int

proc setup*(self: BaseItem, id, name, icon: string, isIdenticon: bool, color, description: string, `type`: int,
  hasUnreadMessages: bool, notificationsCount: int, muted, active: bool, position: int) =
  self.id = id
  self.name = name
  self.icon = icon
  self.isIdenticon = isIdenticon
  self.color = color
  self.description = description
  self.`type` = `type`
  self.hasUnreadMessages = hasUnreadMessages
  self.notificationsCount = notificationsCount
  self.muted = muted
  self.active = active
  self.position = position

proc initBaseItem*(id, name, icon: string, isIdenticon: bool, color, description: string, `type`: int, 
  hasUnreadMessages: bool, notificationsCount: int, muted, active: bool, position: int): BaseItem =
  result = BaseItem()
  result.setup(id, name, icon, isIdenticon, color, description, `type`, hasUnreadMessages, notificationsCount, muted, 
  active, position)

proc delete*(self: BaseItem) = 
  discard

method id*(self: BaseItem): string {.inline base.} = 
  self.id

method name*(self: BaseItem): string {.inline base.} = 
  self.name

method icon*(self: BaseItem): string {.inline base.} = 
  self.icon

method isIdenticon*(self: BaseItem): bool {.inline base.} = 
  self.isIdenticon

method color*(self: BaseItem): string {.inline base.} = 
  self.color

method description*(self: BaseItem): string {.inline base.} = 
  self.description

proc type*(self: BaseItem): int {.inline.} = 
  self.`type`

method hasUnreadMessages*(self: BaseItem): bool {.inline base.} = 
  self.hasUnreadMessages

method `hasUnreadMessages=`*(self: var BaseItem, value: bool) {.inline base.} = 
  self.hasUnreadMessages = value

method notificationsCount*(self: BaseItem): int {.inline base.} = 
  self.notificationsCount

method `notificationsCount=`*(self: var BaseItem, value: int) {.inline base.} = 
  self.notificationsCount = value

method muted*(self: BaseItem): bool {.inline base.} = 
  self.muted

method `muted=`*(self: var BaseItem, value: bool) {.inline base.} = 
  self.muted = value

method active*(self: BaseItem): bool {.inline base.} = 
  self.active

method `active=`*(self: var BaseItem, value: bool) {.inline base.} = 
  self.active = value

method position*(self: BaseItem): int {.inline base.} = 
  self.position

method `position=`*(self: var BaseItem, value: int) {.inline base.} = 
  self.position = value
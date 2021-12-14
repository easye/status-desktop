import NimQml, json
import ../../../../shared_models/message_model
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      
  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc model*(self: View): Model =
    return self.model

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel

  proc toggleReaction*(self: View, messageId: string, emojiId: int) {.slot.} = 
    self.delegate.toggleReaction(messageId, emojiId)

  proc getNamesReactedWithEmojiIdForMessageId*(self: View, messageId: string, emojiId: int): string {.slot.} = 
    return $(%* self.delegate.getNamesReactedWithEmojiIdForMessageId(messageId, emojiId))

  proc pinMessage*(self: View, messageId: string) {.slot.} = 
    self.delegate.pinUnpinMessage(messageId, true)

  proc unpinMessage*(self: View, messageId: string) {.slot.} = 
    self.delegate.pinUnpinMessage(messageId, false)

  proc getMessageByIdAsJson*(self: View, messageId: string): string {.slot.} = 
    let jsonObj = self.model.getMessageByIdAsJson(messageId)  
    if(jsonObj.isNil):
      return ""
    return $jsonObj

  proc getMessageByIndexAsJson*(self: View, index: int): string {.slot.} = 
    let jsonObj = self.model.getMessageByIndexAsJson(index)  
    if(jsonObj.isNil):
      return ""
    return $jsonObj

  proc getChatType*(self: View): int {.slot.} = 
    return self.delegate.getChatType()

  proc getChatColor*(self: View): string {.slot.} = 
    return self.delegate.getChatColor()

  proc amIChatAdmin*(self: View): bool {.slot.} = 
    return self.delegate.amIChatAdmin()

  proc getNumberOfPinnedMessages*(self: View): int {.slot.} = 
    return self.delegate.getNumberOfPinnedMessages()
import sequtils, strutils, sugar, re
import ../service/contacts/dto/contacts
from conversion import SystemTagMapping


proc replacePubKeysWithDisplayNames*(allKnownContacts: seq[ContactsDto], message: string): string =
  let pubKeyPattern = re(r"(@0x[a-f0-9]+)", flags = {reStudy, reIgnoreCase})
  let pubKeys = findAll(message, pubKeyPattern)
  var updatedMessage = message

  for pair in SystemTagMapping:
    updatedMessage = updatedMessage.replaceWord(pair[1], pair[0])

  for pk in pubKeys:
    let pk = pk # TODO https://github.com/nim-lang/Nim/issues/16740
    let listOfMatched = allKnownContacts.filter(x => "@" & x.id == pk)
    if(listOfMatched.len > 0):
      updatedMessage = updatedMessage.replaceWord(pk, "@" & listOfMatched[0].userDefaultDisplayName())

  return updatedMessage

proc replaceMentionsWithPubKeys*(allKnownContacts: seq[ContactsDto], message: string): string =
  let aliasPattern = re(r"(@[A-z][a-z]+ [A-z][a-z]* [A-z][a-z]*)", flags = {reStudy, reIgnoreCase})
  let ensPattern = re(r"(@\w+((\.stateofus)?\.eth))", flags = {reStudy, reIgnoreCase})
  let namePattern = re(r"(@\w+)", flags = {reStudy, reIgnoreCase})

  let aliasMentions = findAll(message, aliasPattern)
  let ensMentions = findAll(message, ensPattern)
  let nameMentions = findAll(message, namePattern)
  var updatedMessage = message

  # replace system tag with system ID
  for pair in SystemTagMapping:
    updatedMessage = updatedMessage.replaceWord(pair[0], pair[1])

  # In the following lines we're free to compare to `x.userDefaultDisplayName()` cause that's actually what we're displaying
  # in the mentions suggestion list.
  for mention in aliasMentions:
    let mention = mention # TODO https://github.com/nim-lang/Nim/issues/16740
    let listOfMatched = allKnownContacts.filter(x => "@" & x.userDefaultDisplayName().toLowerAscii == mention.toLowerAscii)
    if(listOfMatched.len > 0):
      updatedMessage = updatedMessage.replaceWord(mention, '@' & listOfMatched[0].id)

  for mention in ensMentions:
    let mention = mention # TODO https://github.com/nim-lang/Nim/issues/16740
    let listOfMatched = allKnownContacts.filter(x => "@" & x.name.toLowerAscii == mention.toLowerAscii)
    if(listOfMatched.len > 0):
      updatedMessage = updatedMessage.replaceWord(mention, '@' & listOfMatched[0].id)

  for mention in nameMentions:
    let mention = mention # TODO https://github.com/nim-lang/Nim/issues/16740
    let listOfMatched = allKnownContacts.filter(x => x.userDefaultDisplayName().toLowerAscii == mention.toLowerAscii or
      "@" & x.userDefaultDisplayName().toLowerAscii == mention.toLowerAscii)
    if(listOfMatched.len > 0):
      updatedMessage = updatedMessage.replaceWord(mention, '@' & listOfMatched[0].id)
  return updatedMessage


from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *


def input_seed_phrase(input_object_name: str, words: str):
    type_text(input_object_name + "1", words[0])
    type_text(input_object_name + "2", words[1])
    type_text(input_object_name + "3", words[2])
    type_text(input_object_name + "4", words[3])
    type_text(input_object_name + "5", words[4])
    type_text(input_object_name + "6", words[5])
    type_text(input_object_name + "7", words[6])
    type_text(input_object_name + "8", words[7])
    type_text(input_object_name + "9", words[8])
    type_text(input_object_name + "10", words[9])
    type_text(input_object_name + "11", words[10])
    type_text(input_object_name + "12", words[11])

    if len(words) >= 18:
        type_text(input_object_name + "13", words[12])
        type_text(input_object_name + "14", words[13])
        type_text(input_object_name + "15", words[14])
        type_text(input_object_name + "16", words[15])
        type_text(input_object_name + "17", words[16])
        type_text(input_object_name + "18", words[17])

    if len(words) == 24:
        type_text(input_object_name + "19", words[18])
        type_text(input_object_name + "20", words[19])
        type_text(input_object_name + "21", words[20])
        type_text(input_object_name + "22", words[21])
        type_text(input_object_name + "23", words[22])
        type_text(input_object_name + "24", words[23])


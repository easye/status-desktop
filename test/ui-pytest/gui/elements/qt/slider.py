import allure

from gui.elements.qt.object import QObject


class Slider(QObject):

    @property
    @allure.step('Get minimal value {0}')
    def min(self) -> int:
        return int(getattr(self.object, 'from'))

    @property
    @allure.step('Get maximal value {0}')
    def max(self) -> max:
        return int(getattr(self.object, 'to'))

    @property
    @allure.step('Get value {0}')
    def value(self) -> int:
        return int(self.object.value)

    @value.setter
    @allure.step('Set value {1} {0}')
    def value(self, value: int):
        if value != self.value:
            if self.min <= value <= self.max:
                if self.value < value:
                    while self.value < value:
                        self.object.increase()
                if self.value > value:
                    while self.value > value:
                        self.object.decrease()

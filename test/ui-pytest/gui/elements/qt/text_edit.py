import allure

import configs
import driver
from gui.elements.qt.object import QObject


class TextEdit(QObject):

    @property
    @allure.step('Get current text {0}')
    def text(self) -> str:
        return str(self.object.text)

    @text.setter
    @allure.step('Type text {1} {0}')
    def text(self, value: str):
        self.clear()
        self.type_text(value)
        assert driver.waitFor(lambda: self.text == value, configs.timeouts.UI_LOAD_TIMEOUT_MSEC), \
            f'Type text failed, value in field: "{self.text}", expected: {value}'

    @allure.step('Type: {1} in {0}')
    def type_text(self, value: str):
        driver.type(self.object, value)
        return self

    @allure.step('Clear {0}')
    def clear(self):
        self.object.clear()
        assert driver.waitFor(lambda: not self.text), \
            f'Clear text field failed, value in field: "{self.text}"'
        return self

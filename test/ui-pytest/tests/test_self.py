import logging

import allure

import driver

_logger = logging.getLogger(__name__)
pytestmark = allure.suite("Self")


def test_start_aut(main_window):
    driver.context.detach()

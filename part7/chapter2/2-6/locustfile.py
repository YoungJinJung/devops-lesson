#!/usr/bin/env python

# Copyright 2020 The klocust Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


from locust import HttpUser, TaskSet, task, between, events, constant
from locust.exception import StopUser
import random

DEBUG_MODE = False


def print_log(url, response):
    if not DEBUG_MODE:
        return

    if response.status_code in [200, 201]:
        print(f'[{response.status_code}] {url}')
    else:
        print(f'[{response.status_code}] {url} {response.text}')


class WebsiteTasks(TaskSet):

    def __init__(self, parent):
        super().__init__(parent)
        self.default_headers = None

    # call with starting new test
    @events.test_start.add_listener
    def on_test_start(**kwargs):
        return

    # call with stopping new test
    @events.test_stop.add_listener
    def on_test_stop(**kwargs):
        return

    # get, post, put, delete helper methods
    def get(self, url, headers=None, name=None):
        response = self.client.get(url, headers=headers or self.default_headers, name=name or url)
        print_log(url, response)
        return response


    # call with starting new task
    def on_start(self):
        # self.login("email", "password")
        return

    # call with stopping new task
    def on_stop(self):
        # self.logout()
        return

    ######################################################################
    # write your tasks ###################################################
    ######################################################################
    @task(60)
    def getUserInfo(self):
        self.get("/ceres/api/userinfo/"+str(random.randrange(1,12)))

    @task(40)
    def getServiceName(self):
        self.get("/ceres/api/serviceName")


class WebsiteUser(HttpUser):
    tasks = [WebsiteTasks]

    # If you want no wait time between tasks
    # wait_time = constant(0)
    wait_time = between(1, 2)

    # default target host
    host = "http://192.168.120.109:8001"

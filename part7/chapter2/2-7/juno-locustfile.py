from locust import HttpUser, task

class GetServiceName(HttpUser):
    @task
    def get_juno_serviceName(self):
        self.client.get("/juno/api/serviceName")
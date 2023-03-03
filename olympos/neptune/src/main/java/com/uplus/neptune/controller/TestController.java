package com.uplus.neptune.controller;

import com.uplus.neptune.service.RestTemplateService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.support.HttpRequestHandlerServlet;

@RestController
public class TestController {
    @Value("${spring.application.name}")
    private String responseData;
    private final RestTemplateService restTemplateService;

    public TestController(RestTemplateService restTemplateService) {
        this.restTemplateService = restTemplateService;
    }

    @GetMapping("/neptune/api/serviceName")
    public String getServiceName(){
        return responseData;
    }

    @GetMapping("/neptune/api/userinfo/{id}")
    public String getUserInfo(@PathVariable int id) {
        return restTemplateService.callCeres(id);
    }

}

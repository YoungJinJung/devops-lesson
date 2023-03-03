package com.uplus.aurora.controller;

import com.uplus.aurora.service.RestTemplateService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {
    @Value("${spring.application.name}")
    private String responseData;
    private final RestTemplateService restTemplateService;

    public TestController(RestTemplateService restTemplateService) {
        this.restTemplateService = restTemplateService;
    }

    @GetMapping("/aurora/api/serviceName")
    public String getServiceName(){
        return responseData;
    }

    @GetMapping("/aurora/api/userinfo/{id}")
    public String getUserInfo(@PathVariable int id) {
        return restTemplateService.callCeres(id);
    }

}

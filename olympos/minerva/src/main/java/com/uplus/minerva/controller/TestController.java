package com.uplus.minerva.controller;

import com.uplus.minerva.service.RestTemplateService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {
    @Value("${spring.application.name}")
    private String responseData;
    private final RestTemplateService restTemplateService;

    public TestController(RestTemplateService restTemplateService) {
        this.restTemplateService = restTemplateService;
    }

    @GetMapping("/minerva/api/serviceName")
    public String getServiceName(){
        return responseData;
    }

    @GetMapping("/minerva/api/luna")
    public String getCallLuna(){
        return restTemplateService.callLuna();
    }
}

package com.uplus.juno.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {
    @Value("${spring.application.name}")

    private String responseData;

    @GetMapping("/juno/api/serviceName")
    public String getServiceName(){
        return responseData;
    }
}

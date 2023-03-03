package com.uplus.jupiter.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@RestController
public class TestController {
    @Value("${spring.application.name}")
    private String responseData;

    @GetMapping("/jupiter/api/serviceName")
    public String getServiceName(){
        return responseData;
    }
}

package com.uplus.minerva.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;

@Service
public class RestTemplateService {
    @Value("${request.url}")
    private String requestUrl;

    @Value("${request.port}")
    private String requestPort;
    @Value("${request.path}")
    private String requestPath;

    public String callLuna(){
        // uri 주소 생성
        URI uri = UriComponentsBuilder.newInstance()
                .scheme("http")
                .host(requestUrl)
                .port(requestPort)
                .path(requestPath)
                .encode().build().toUri();

        System.out.println("Send request : " + uri);

        RestTemplate restTemplate = new RestTemplate();

        ResponseEntity<String> result = restTemplate.getForEntity(uri, String.class);

        return result.getBody();
    }
}

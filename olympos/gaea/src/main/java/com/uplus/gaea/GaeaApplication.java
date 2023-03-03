package com.uplus.gaea;

import de.codecentric.boot.admin.server.config.EnableAdminServer;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@EnableAdminServer
public class GaeaApplication {

    public static void main(String[] args) {
        SpringApplication.run(GaeaApplication.class, args);
    }

}

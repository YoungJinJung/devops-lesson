package com.uplus.ceres;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@EnableJpaRepositories
@SpringBootApplication
public class CeresApplication {

    public static void main(String[] args) {
        SpringApplication.run(CeresApplication.class, args);
    }

}

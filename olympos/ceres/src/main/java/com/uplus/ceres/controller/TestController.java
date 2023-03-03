package com.uplus.ceres.controller;
import com.uplus.ceres.dto.ResponseDto;
import com.uplus.ceres.model.UserInfo;
import com.uplus.ceres.service.UserService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {
    @Value("${spring.application.name}")
    private String responseData;

    private UserService userService;

    private TestController(UserService userService) { this.userService = userService; }

    @GetMapping("/ceres/api/serviceName")
    public String getServiceName(){
        return responseData;
    }

    @GetMapping("/ceres/api/userinfo/{id}")
    public ResponseDto<UserInfo> getUserInfo(@PathVariable int id) {
        ResponseDto<UserInfo> result ;
        try {
            UserInfo userInfo = userService.getUserInfoById(id);
            result = new ResponseDto<>(HttpStatus.OK, userInfo);
        } catch (IllegalArgumentException e) {
            result = new ResponseDto<>(HttpStatus.INTERNAL_SERVER_ERROR, null);
        }
        return result;
    }
}

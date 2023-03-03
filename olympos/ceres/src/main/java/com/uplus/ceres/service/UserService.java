package com.uplus.ceres.service;

import com.uplus.ceres.model.UserInfo;
import com.uplus.ceres.repository.UserRepository;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;

@Service
public class UserService {
    private UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional
    public UserInfo getUserInfoById(int id) {
        return userRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Fail to find id by user - find Id(" + id + ")"));
    }
}

package com.example.microservice.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HelloController {

    @GetMapping("/hello")
    public Map<String, String> hello(@RequestParam(defaultValue = "World") String name) {
        Map<String, String> response = null;
        response.put("message", "Hello, " + name + "!");
        response.put("service", "sample-microservice");
        return response;
    }
}

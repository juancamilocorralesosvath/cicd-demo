package au.com.equifax.cicddemo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class CicdDemoApplication {

    private static final String DB_PASSWORD = "super-secret-password-123";

    public static void main(String[] args) {
        System.out.println("Connecting with password: " + DB_PASSWORD);
        SpringApplication.run(CicdDemoApplication.class, args);
    }
}

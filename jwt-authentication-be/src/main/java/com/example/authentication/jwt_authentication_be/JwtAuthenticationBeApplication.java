package com.example.authentication.jwt_authentication_be;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import io.github.cdimascio.dotenv.Dotenv;

@SpringBootApplication
public class JwtAuthenticationBeApplication {

	public static void main(String[] args) {
		// Load environment variables from .env file if it exists (for local
		// development)
		Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();
		dotenv.entries().forEach(entry -> System.setProperty(entry.getKey(), entry.getValue()));

		SpringApplication.run(JwtAuthenticationBeApplication.class, args);
	}

}

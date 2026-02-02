package br.edu.ifs.academico.Programacao_Web_I.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("*") // Permite tudo temporariamente para facilitar o teste
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS");
    }
}
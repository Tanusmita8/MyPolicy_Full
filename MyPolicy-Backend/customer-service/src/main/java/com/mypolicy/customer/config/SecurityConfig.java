package com.mypolicy.customer.config;

import com.mypolicy.customer.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

/**
 * Security Configuration for Customer Service
 * 
 * CRITICAL SECURITY IMPLEMENTATION:
 * - JWT Authentication Filter validates all incoming requests
 * - Stateless session management (no server-side sessions)
 * - BCrypt password encoding
 * - Public endpoints: /register, /login, /health, GET /api/v1/customers/** (read-only for BFF aggregation)
 * - Mutations (PUT etc.) require valid JWT token
 */
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

  private final JwtAuthenticationFilter jwtAuthFilter;

  /** BFF and tools call these without a Bearer token; use explicit matchers so every GET under /customers is public. */
  private static final AntPathRequestMatcher CUSTOMER_PUBLIC_GET =
      new AntPathRequestMatcher("/api/v1/customers/**", HttpMethod.GET.name());
  private static final AntPathRequestMatcher CUSTOMER_PUBLIC_HEAD =
      new AntPathRequestMatcher("/api/v1/customers/**", HttpMethod.HEAD.name());

  @Bean
  public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http
        .csrf(csrf -> csrf.disable())
        .authorizeHttpRequests(auth -> auth
            .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
            // Public endpoints - no authentication required (BFF internal calls + health)
            .requestMatchers("/api/v1/customers/register", "/api/v1/customers/login").permitAll()
            // BFF: portfolio, insights, and Feign reads (getCustomerById, search, details) — no JWT for GET
            .requestMatchers(CUSTOMER_PUBLIC_GET, CUSTOMER_PUBLIC_HEAD).permitAll()
            .requestMatchers("/", "/health", "/api/health", "/api/v1/health", "/api/v1/ping").permitAll()
            .requestMatchers("/actuator/**", "/api/v1/actuator/**").permitAll()
            // Mutations require JWT
            .anyRequest().authenticated())
        // Stateless session management (JWT-based)
        .sessionManagement(sess -> sess.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        // Add JWT filter before UsernamePasswordAuthenticationFilter
        .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

    return http.build();
  }

  @Bean
  public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
  }

  @Bean
  public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
    return config.getAuthenticationManager();
  }
}

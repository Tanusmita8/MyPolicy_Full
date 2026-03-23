package com.mypolicy.customer.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * JWT Authentication Filter - Validates JWT tokens on incoming requests
 * This filter intercepts every request and validates the JWT token if present
 * 
 * CRITICAL SECURITY COMPONENT:
 * - Extracts JWT from Authorization header
 * - Validates token signature and expiration
 * - Sets Spring Security authentication context
 * - Allows public endpoints to bypass authentication
 */
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

  private static final AntPathRequestMatcher PUBLIC_CUSTOMER_READS =
      new AntPathRequestMatcher("/api/v1/customers/**", HttpMethod.GET.name());

  private final JwtService jwtService;
  private final UserDetailsService userDetailsService;

  @Override
  protected boolean shouldNotFilter(HttpServletRequest request) {
    // Skip JWT for all read-only customer APIs used by BFF (Feign has no end-user Bearer token)
    return PUBLIC_CUSTOMER_READS.matches(request);
  }

  @Override
  protected void doFilterInternal(
      @NonNull HttpServletRequest request,
      @NonNull HttpServletResponse response,
      @NonNull FilterChain filterChain) throws ServletException, IOException {

    // Extract Authorization header
    final String authHeader = request.getHeader("Authorization");
    final String jwt;
    final String username;

    // Check if Authorization header is present and starts with "Bearer "
    if (authHeader == null || !authHeader.startsWith("Bearer ")) {
      filterChain.doFilter(request, response);
      return;
    }

    // Extract JWT token (remove "Bearer " prefix)
    jwt = authHeader.substring(7);

    try {
      // Extract username from JWT
      username = jwtService.extractUsername(jwt);

      // If username is valid and user is not already authenticated
      if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {

        // Load user details from database
        UserDetails userDetails = this.userDetailsService.loadUserByUsername(username);

        // Validate token
        if (jwtService.isTokenValid(jwt, userDetails.getUsername())) {
          // Create authentication token
          UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
              userDetails,
              null,
              userDetails.getAuthorities());

          // Set authentication details
          authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

          // Set authentication in security context
          SecurityContextHolder.getContext().setAuthentication(authToken);
        }
      }
    } catch (Exception e) {
      // Log warning and continue without authentication
      logger.warn("JWT validation failed: " + e.getMessage());
    }

    // Continue filter chain
    filterChain.doFilter(request, response);
  }
}

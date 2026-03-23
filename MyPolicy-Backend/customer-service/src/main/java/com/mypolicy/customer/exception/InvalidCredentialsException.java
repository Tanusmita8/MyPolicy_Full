package com.mypolicy.customer.exception;

/**
 * Exception thrown when login credentials are invalid
 */
public class InvalidCredentialsException extends RuntimeException {
  
  public InvalidCredentialsException() {
    super("Invalid full name or PAN");
  }

  public InvalidCredentialsException(String message) {
    super(message);
  }
}

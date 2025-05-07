package com.gabriel.financia.backend.dto;

public class LoginResponse {
    private Long id;
    private String name;
    private boolean firstAccess;

    public LoginResponse() {}

    public LoginResponse(Long id, String name, boolean firstAccess) {
        this.id = id;
        this.name = name;
        this.firstAccess = firstAccess;
    }

    public Long getId() { return id; }
    public String getName() { return name; }
    public boolean isFirstAccess() { return firstAccess; }

    public void setId(Long id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setFirstAccess(boolean firstAccess) { this.firstAccess = firstAccess; }
}
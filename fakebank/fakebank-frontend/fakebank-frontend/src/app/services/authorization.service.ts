import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AuthorizationService {
  private apiUrl = 'http://localhost:8081/api/authorization';

  constructor(private http: HttpClient) {}

  // Busca solicitações pendentes
getPendingRequests(cpf: string, bank: string): Observable<any[]> {
  return this.http.get<any[]>(`${this.apiUrl}/pending/${cpf}/${bank}`);
}

  // Aprova uma solicitação
approveRequest(id: number): Observable<any> {
  return this.http.patch(`${this.apiUrl}/approve/${id}`, null, {
    responseType: 'text'
  });
}
}

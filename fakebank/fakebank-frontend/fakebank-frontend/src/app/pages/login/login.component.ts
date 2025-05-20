import { Component } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html'
})
export class LoginComponent {
  cpf = '';
  password = '';
  bank = '';

  constructor(private http: HttpClient, private router: Router) {}

  login() {
    const headers = new HttpHeaders({
      Authorization: 'Basic ' + btoa(this.cpf + ':' + this.password)
    });

    this.http.post<any>(`http://localhost:8081/api/auth/login?bank=${this.bank}`, {}, { headers })
      .subscribe({
        next: (res) => {
          alert('Login realizado com sucesso!');

          // Verifica o banco e redireciona para a rota correta
          switch (res.bank) {
            case 'NIBANK':
              this.router.navigate(['/nibank']);
              break;
            case 'BRAZILS_BANK':
              this.router.navigate(['/brazils-bank']);
              break;
            case 'INTIBANK':
              this.router.navigate(['/intibank']);
              break;
            default:
              alert('Banco não reconhecido!');
          }
        },
        error: (err) => {
          alert('Erro ao logar: ' + err.error);
        }
      });
  }
}

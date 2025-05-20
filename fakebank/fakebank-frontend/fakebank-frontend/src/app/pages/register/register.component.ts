import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html'
})
export class RegisterComponent {
  name = '';
  cpf = '';
  password = '';
  bank = '';

  constructor(private http: HttpClient) {}

  register() {
    const body = {
      name: this.name,
      cpf: this.cpf,
      password: this.password,
      bank: this.bank
    };

    this.http.post('http://localhost:8081/api/auth/signup', body)
      .subscribe({
        next: (res) => {
          alert('Registro realizado com sucesso!');
        },
        error: (err) => {
          if (err.status === 200 || err.status === 201) {
            alert('Registro realizado com sucesso!');
          } else {
            alert('Erro ao registrar: ' + JSON.stringify(err));
          }
        }
      });
  }
}

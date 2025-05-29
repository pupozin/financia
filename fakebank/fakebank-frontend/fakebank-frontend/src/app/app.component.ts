import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'fakebank-frontend';
    isLoggedIn(): boolean {
    return !!localStorage.getItem('cpf'); // se tiver CPF, está logado
  }
}

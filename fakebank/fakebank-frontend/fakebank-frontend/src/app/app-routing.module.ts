import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './pages/login/login.component';
import { RegisterComponent } from './pages/register/register.component';
import { NibankComponent } from './components/nibank/nibank.component';
import { BrazilsBankComponent } from './components/brazils-bank/brazils-bank.component';
import { IntibankComponent } from './components/intibank/intibank.component';

const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },
  { path: 'nibank', component: NibankComponent },
  { path: 'brazils-bank', component: BrazilsBankComponent },
  { path: 'intibank', component: IntibankComponent },
  { path: '', redirectTo: 'login', pathMatch: 'full' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule {}
import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-nibank',
  templateUrl: './nibank.component.html'
})
export class NibankComponent {
  cpf = localStorage.getItem('cpf');
  bank = 'NIBANK';

  income = {
    description: '',
    amount: 0,
    category: '',
    payer: ''
  };

  debit = {
    description: '',
    amount: 0,
    category: '',
    payer: ''
  };

  fatura: any[] = [];

  constructor(private http: HttpClient) {}

addIncome() {
  const body = {
    cpf: this.cpf,
    bank: this.bank,
    description: this.income.description,
    amount: Number(this.income.amount), // garante que é number
    category: this.income.category,
    payer: this.income.payer,
    type: 'INCOME',
    method: 'PIX',
    installments: 1
  };

  this.http.post('http://localhost:8081/api/transaction/income', body, { responseType: 'text' })
  .subscribe({
    next: () => alert('Dinheiro adicionado com sucesso'),
    error: (err) => console.error('Erro:', err)
  });
}


  payWithDebit() {
    const body = {
      cpf: this.cpf,
      bank: this.bank,
      description: this.debit.description,
      amount: this.debit.amount,
      category: this.debit.category,
      payer: this.debit.payer,
      type: 'EXPENSE',
      method: 'DEBIT'
    };

    this.http.post('http://localhost:8081/api/transaction/debit', body)
      .subscribe(() => alert('Pagamento realizado com sucesso'));
  }

  viewInvoice() {
    const today = new Date();
    const month = today.getMonth() + 1;
    const year = today.getFullYear();

    this.http.get<any[]>(`http://localhost:8081/api/transaction/invoice/${this.cpf}/${this.bank}/${month}/${year}`)
      .subscribe(data => {
        this.fatura = data;
      });
  }
}

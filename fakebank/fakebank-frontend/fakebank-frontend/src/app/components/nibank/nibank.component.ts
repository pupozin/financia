import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';

@Component({
  selector: 'app-nibank',
  templateUrl: './nibank.component.html',
  styleUrls: ['./nibank.component.css']
})
export class NibankComponent {
  cpf = localStorage.getItem('cpf');
  bank = 'NIBANK';

    constructor(private http: HttpClient, private router: Router) {}

logout() {
  localStorage.removeItem('cpf');
  this.router.navigate(['/login']);
}


  saldo: number | null = null;
  fatura: any[] = [];
  parcelas: any[] = [];

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

  credit = {
    description: '',
    amount: 0,
    category: '',
    payer: '',
    installments: 1
  };


  getSaldo() {
    this.http.get<any>(`http://localhost:8081/api/transaction/balance/${this.cpf}/${this.bank}`)
      .subscribe(data => {
        this.saldo = data.balance;
      });
  }

  addIncome() {
    const body = {
      cpf: this.cpf,
      bank: this.bank,
      description: this.income.description,
      amount: Number(this.income.amount),
      category: this.income.category,
      payer: this.income.payer,
      type: 'INCOME',
      method: 'PIX',
      installments: 1
    };

    this.http.post('http://localhost:8081/api/transaction/income', body, { responseType: 'text' })
      .subscribe({
        next: () => {
          alert('Dinheiro adicionado com sucesso');
          this.getSaldo();
        },
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
      .subscribe(() => {
        alert('Pagamento realizado com sucesso');
        this.getSaldo();
      });
  }

  payWithCredit() {
    const body = {
      cpf: this.cpf,
      bank: this.bank,
      description: this.credit.description,
      amount: Number(this.credit.amount),
      category: this.credit.category,
      payer: this.credit.payer,
      type: 'EXPENSE',
      method: 'CREDIT',
      installments: this.credit.installments
    };

    this.http.post('http://localhost:8081/api/transaction/credit', body)
      .subscribe(() => {
        alert('Pagamento no crédito registrado com sucesso');
      });
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

  getUnpaidInstallments() {
    this.http.get<any[]>(`http://localhost:8081/api/transaction/unpaid-installments/${this.cpf}/${this.bank}`)
      .subscribe(data => {
        this.parcelas = data;
      });
  }

  payInstallment(id: number) {
    this.http.post(`http://localhost:8081/api/transaction/pay-installment/${id}`, {}, { responseType: 'text' })
      .subscribe({
        next: () => {
          alert('Parcela paga com sucesso!');
          this.getUnpaidInstallments();
          this.getSaldo();
        },
        error: (err) => console.error('Erro ao pagar parcela:', err)
      });
  }
}

import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BrazilsBankComponent } from './brazils-bank.component';

describe('BrazilsBankComponent', () => {
  let component: BrazilsBankComponent;
  let fixture: ComponentFixture<BrazilsBankComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ BrazilsBankComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(BrazilsBankComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

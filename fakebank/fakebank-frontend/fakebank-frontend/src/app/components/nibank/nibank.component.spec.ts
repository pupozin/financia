import { ComponentFixture, TestBed } from '@angular/core/testing';

import { NibankComponent } from './nibank.component';

describe('NibankComponent', () => {
  let component: NibankComponent;
  let fixture: ComponentFixture<NibankComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ NibankComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(NibankComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

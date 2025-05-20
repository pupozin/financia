import { ComponentFixture, TestBed } from '@angular/core/testing';

import { IntibankComponent } from './intibank.component';

describe('IntibankComponent', () => {
  let component: IntibankComponent;
  let fixture: ComponentFixture<IntibankComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ IntibankComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(IntibankComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

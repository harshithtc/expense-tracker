from sqlalchemy.orm import Session
from . import models, schemas, auth
from typing import List, Optional

# User CRUD
def get_user_by_username(db: Session, username: str):
    return db.query(models.User).filter(models.User.username == username).first()

def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()

def create_user(db: Session, user: schemas.UserCreate):
    hashed_password = auth.get_password_hash(user.password)
    db_user = models.User(
        email=user.email,
        username=user.username,
        hashed_password=hashed_password
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

# Category CRUD
def get_categories(db: Session, user_id: int):
    return db.query(models.Category).filter(models.Category.user_id == user_id).all()

def create_category(db: Session, category: schemas.CategoryCreate, user_id: int):
    db_category = models.Category(**category.dict(), user_id=user_id)
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return db_category

# Expense CRUD
def get_expenses(db: Session, user_id: int, skip: int = 0, limit: int = 100):
    return db.query(models.Expense).filter(
        models.Expense.user_id == user_id
    ).offset(skip).limit(limit).all()

def create_expense(db: Session, expense: schemas.ExpenseCreate, user_id: int):
    db_expense = models.Expense(**expense.dict(), user_id=user_id)
    db.add(db_expense)
    db.commit()
    db.refresh(db_expense)
    return db_expense

def get_expense(db: Session, expense_id: int, user_id: int):
    return db.query(models.Expense).filter(
        models.Expense.id == expense_id,
        models.Expense.user_id == user_id
    ).first()

def update_expense(db: Session, expense_id: int, expense_update: schemas.ExpenseUpdate, user_id: int):
    db_expense = get_expense(db, expense_id, user_id)
    if db_expense:
        update_data = expense_update.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_expense, field, value)
        db.commit()
        db.refresh(db_expense)
    return db_expense

def delete_expense(db: Session, expense_id: int, user_id: int):
    db_expense = get_expense(db, expense_id, user_id)
    if db_expense:
        db.delete(db_expense)
        db.commit()
    return db_expense

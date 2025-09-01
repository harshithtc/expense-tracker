from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBasicCredentials
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from datetime import timedelta
from typing import List

from .backend.app import crud, models, schemas, auth
from .app.database import SessionLocal, engine, get_db

# Create tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Expense Tracker API", version="1.0.0")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your frontend domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Auth endpoints
@app.post("/auth/register", response_model=schemas.UserResponse)
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    # Check if user exists
    db_user = crud.get_user_by_username(db, username=user.username)
    if db_user:
        raise HTTPException(
            status_code=400,
            detail="Username already registered"
        )
    
    db_user = crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(
            status_code=400,
            detail="Email already registered"
        )
    
    return crud.create_user(db=db, user=user)

@app.post("/auth/login", response_model=schemas.Token)
def login(credentials: HTTPBasicCredentials, db: Session = Depends(get_db)):
    user = auth.authenticate_user(db, credentials.username, credentials.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user
    }

# Category endpoints
@app.get("/categories", response_model=List[schemas.CategoryResponse])
def get_categories(
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    return crud.get_categories(db=db, user_id=current_user.id)

@app.post("/categories", response_model=schemas.CategoryResponse)
def create_category(
    category: schemas.CategoryCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    return crud.create_category(db=db, category=category, user_id=current_user.id)

# Expense endpoints
@app.get("/expenses", response_model=List[schemas.ExpenseResponse])
def get_expenses(
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    return crud.get_expenses(db=db, user_id=current_user.id, skip=skip, limit=limit)

@app.post("/expenses", response_model=schemas.ExpenseResponse)
def create_expense(
    expense: schemas.ExpenseCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    return crud.create_expense(db=db, expense=expense, user_id=current_user.id)

@app.get("/expenses/{expense_id}", response_model=schemas.ExpenseResponse)
def get_expense(
    expense_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    expense = crud.get_expense(db=db, expense_id=expense_id, user_id=current_user.id)
    if not expense:
        raise HTTPException(status_code=404, detail="Expense not found")
    return expense

@app.put("/expenses/{expense_id}", response_model=schemas.ExpenseResponse)
def update_expense(
    expense_id: int,
    expense_update: schemas.ExpenseUpdate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    expense = crud.update_expense(
        db=db, expense_id=expense_id, expense_update=expense_update, user_id=current_user.id
    )
    if not expense:
        raise HTTPException(status_code=404, detail="Expense not found")
    return expense

@app.delete("/expenses/{expense_id}")
def delete_expense(
    expense_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    expense = crud.delete_expense(db=db, expense_id=expense_id, user_id=current_user.id)
    if not expense:
        raise HTTPException(status_code=404, detail="Expense not found")
    return {"message": "Expense deleted successfully"}

@app.get("/")
def root():
    return {"message": "Expense Tracker API is running!"}

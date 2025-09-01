from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional, List

# User Schemas
class UserBase(BaseModel):
    email: EmailStr
    username: str

class UserCreate(UserBase):
    password: str

class UserResponse(UserBase):
    id: int
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

# Category Schemas
class CategoryBase(BaseModel):
    name: str
    color: Optional[str] = "#6366f1"

class CategoryCreate(CategoryBase):
    pass

class CategoryResponse(CategoryBase):
    id: int
    user_id: int
    
    class Config:
        from_attributes = True

# Expense Schemas
class ExpenseBase(BaseModel):
    title: str
    amount: float
    description: Optional[str] = None
    category_id: int

class ExpenseCreate(ExpenseBase):
    pass

class ExpenseUpdate(BaseModel):
    title: Optional[str] = None
    amount: Optional[float] = None
    description: Optional[str] = None
    category_id: Optional[int] = None

class ExpenseResponse(ExpenseBase):
    id: int
    date: datetime
    user_id: int
    category: Optional[CategoryResponse] = None
    
    class Config:
        from_attributes = True

# Auth Schemas
class Token(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse

class TokenData(BaseModel):
    username: Optional[str] = None

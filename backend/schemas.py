from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

# User schemas
class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    role: str

class UserCreate(UserBase):
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(UserBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Class schemas
class ClassBase(BaseModel):
    name: str
    description: Optional[str] = None
    subject: str

class ClassCreate(ClassBase):
    pass

class ClassResponse(ClassBase):
    id: int
    teacher_id: int
    class_code: str
    is_active: bool
    created_at: datetime
    teacher: UserResponse

    class Config:
        from_attributes = True

# Assignment schemas
class AssignmentBase(BaseModel):
    title: str
    description: Optional[str] = None
    due_date: datetime

class AssignmentCreate(AssignmentBase):
    class_id: int

class AssignmentResponse(AssignmentBase):
    id: int
    class_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Submission schemas
class SubmissionBase(BaseModel):
    content: str

class SubmissionCreate(SubmissionBase):
    assignment_id: int

class SubmissionResponse(SubmissionBase):
    id: int
    student_id: int
    assignment_id: int
    submitted_at: datetime
    grade: Optional[int] = None

    class Config:
        from_attributes = True 
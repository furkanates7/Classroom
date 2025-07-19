from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from typing import List
import uvicorn

from database import get_db, engine
from models import Base
from schemas import UserCreate, UserLogin, UserResponse, ClassCreate, ClassResponse, AssignmentCreate, AssignmentResponse
from auth import create_access_token, get_current_user, authenticate_user
from crud import create_user, get_user_by_email, create_class, get_classes_by_teacher, get_student_enrollments, get_class_by_code, enroll_student_in_class, create_assignment, get_assignments_by_class
from models import Class, Enrollment

# Database tablolarını oluştur
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Classroom API",
    description="Öğrenciler ve öğretmenler için eğitim platformu API'si",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

security = HTTPBearer()

@app.get("/")
async def root():
    return {"message": "Classroom API'ye Hoş Geldiniz!"}

@app.post("/auth/register", response_model=UserResponse)
async def register(user: UserCreate, db: Session = Depends(get_db)):
    """Kullanıcı kaydı"""
    db_user = get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(
            status_code=400,
            detail="Bu email adresi zaten kayıtlı"
        )
    return create_user(db=db, user=user)

@app.post("/auth/login")
async def login(user_credentials: UserLogin, db: Session = Depends(get_db)):
    """Kullanıcı girişi"""
    user = authenticate_user(db, user_credentials.email, user_credentials.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Geçersiz email veya şifre",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer", "user": user}

@app.get("/users/me", response_model=UserResponse)
async def get_current_user_info(current_user = Depends(get_current_user)):
    """Mevcut kullanıcı bilgilerini getir"""
    return current_user

@app.post("/classes", response_model=ClassResponse)
async def create_new_class(
    class_data: ClassCreate,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Yeni sınıf oluştur (sadece öğretmenler)"""
    if current_user.role != "teacher":
        raise HTTPException(
            status_code=403,
            detail="Sadece öğretmenler sınıf oluşturabilir"
        )
    return create_class(db=db, class_data=class_data, teacher_id=current_user.id)

@app.get("/classes", response_model=List[ClassResponse])
async def get_my_classes(
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Kullanıcının sınıflarını getir"""
    if current_user.role == "teacher":
        return get_classes_by_teacher(db, teacher_id=current_user.id)
    else:
        # Öğrenci için sınıf listesi
        enrollments = get_student_enrollments(db, student_id=current_user.id)
        classes = []
        for enrollment in enrollments:
            class_data = db.query(Class).filter(Class.id == enrollment.class_id).first()
            if class_data:
                classes.append(class_data)
        return classes

@app.post("/classes/{class_code}/join")
async def join_class(
    class_code: str,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Sınıfa katıl (sadece öğrenciler)"""
    if current_user.role != "student":
        raise HTTPException(
            status_code=403,
            detail="Sadece öğrenciler sınıfa katılabilir"
        )
    
    class_data = get_class_by_code(db, class_code=class_code)
    if not class_data:
        raise HTTPException(
            status_code=404,
            detail="Sınıf bulunamadı"
        )
    
    enrollment = enroll_student_in_class(db, student_id=current_user.id, class_id=int(class_data.id))
    return {"message": "Sınıfa başarıyla katıldınız", "class": class_data}

@app.get("/classes/{class_id}/assignments", response_model=List[AssignmentResponse])
async def get_class_assignments(
    class_id: int,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Sınıfın ödevlerini getir"""
    # Kullanıcının bu sınıfa erişim yetkisi olup olmadığını kontrol et
    if current_user.role == "teacher":
        class_data = db.query(Class).filter(Class.id == class_id, Class.teacher_id == current_user.id).first()
    else:
        enrollment = db.query(Enrollment).filter(
            Enrollment.class_id == class_id,
            Enrollment.student_id == current_user.id
        ).first()
        if not enrollment:
            raise HTTPException(status_code=403, detail="Bu sınıfa erişim yetkiniz yok")
    
    return get_assignments_by_class(db, class_id=class_id)

@app.post("/classes/{class_id}/assignments", response_model=AssignmentResponse)
async def create_new_assignment(
    class_id: int,
    assignment_data: AssignmentCreate,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Ödev oluştur (sadece öğretmenler)"""
    if current_user.role != "teacher":
        raise HTTPException(
            status_code=403,
            detail="Sadece öğretmenler ödev oluşturabilir"
        )
    
    # Öğretmenin bu sınıfın sahibi olup olmadığını kontrol et
    class_data = db.query(Class).filter(Class.id == class_id, Class.teacher_id == current_user.id).first()
    if not class_data:
        raise HTTPException(status_code=403, detail="Bu sınıfın öğretmeni değilsiniz")
    
    return create_assignment(db, assignment_data=assignment_data, class_id=class_id)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000) 
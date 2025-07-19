from sqlalchemy.orm import Session
from models import User, Class, Assignment, Submission, Enrollment
from schemas import UserCreate, ClassCreate, AssignmentCreate
import secrets
import string
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password):
    return pwd_context.hash(password)

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def create_user(db: Session, user: UserCreate):
    hashed_password = get_password_hash(user.password)
    db_user = User(
        email=user.email,
        full_name=user.full_name,
        hashed_password=hashed_password,
        role=user.role
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def generate_class_code():
    """6 karakterlik benzersiz sınıf kodu oluştur"""
    alphabet = string.ascii_uppercase + string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(6))

def create_class(db: Session, class_data: ClassCreate, teacher_id: int):
    class_code = generate_class_code()
    db_class = Class(
        name=class_data.name,
        description=class_data.description,
        subject=class_data.subject,
        teacher_id=teacher_id,
        class_code=class_code
    )
    db.add(db_class)
    db.commit()
    db.refresh(db_class)
    return db_class

def get_classes_by_teacher(db: Session, teacher_id: int):
    return db.query(Class).filter(Class.teacher_id == teacher_id).all()

def get_class_by_code(db: Session, class_code: str):
    return db.query(Class).filter(Class.class_code == class_code).first()

def enroll_student_in_class(db: Session, student_id: int, class_id: int):
    # Öğrencinin zaten kayıtlı olup olmadığını kontrol et
    existing_enrollment = db.query(Enrollment).filter(
        Enrollment.student_id == student_id,
        Enrollment.class_id == class_id
    ).first()
    
    if existing_enrollment:
        return existing_enrollment
    
    enrollment = Enrollment(student_id=student_id, class_id=class_id)
    db.add(enrollment)
    db.commit()
    db.refresh(enrollment)
    return enrollment

def create_assignment(db: Session, assignment_data: AssignmentCreate, class_id: int):
    db_assignment = Assignment(
        title=assignment_data.title,
        description=assignment_data.description,
        due_date=assignment_data.due_date,
        class_id=class_id
    )
    db.add(db_assignment)
    db.commit()
    db.refresh(db_assignment)
    return db_assignment

def get_assignments_by_class(db: Session, class_id: int):
    return db.query(Assignment).filter(Assignment.class_id == class_id).all()

def create_submission(db: Session, submission_data, student_id: int):
    db_submission = Submission(
        content=submission_data.content,
        assignment_id=submission_data.assignment_id,
        student_id=student_id
    )
    db.add(db_submission)
    db.commit()
    db.refresh(db_submission)
    return db_submission

def get_submissions_by_assignment(db: Session, assignment_id: int):
    return db.query(Submission).filter(Submission.assignment_id == assignment_id).all()

def get_student_enrollments(db: Session, student_id: int):
    return db.query(Enrollment).filter(Enrollment.student_id == student_id).all() 
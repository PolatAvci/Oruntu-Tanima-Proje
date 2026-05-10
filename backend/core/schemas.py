from typing import Generic, TypeVar, Optional, List, Any
from pydantic import BaseModel

# T, içine koyacağımız herhangi bir DTO'yu temsil eder (Generic Type)
T = TypeVar('T')

class ApiResponse(BaseModel, Generic[T]):
    success: bool
    message: str
    status: int
    data: Optional[T] = None        # Başarılıysa DTO buraya gelecek
    errors: Optional[List[str]] = None # Başarısızsa hatalar buraya gelecek

    # Başarılı yanıtlar için Factory Method
    @classmethod
    def success_response(cls, data: T, message: str = "Success", status: int = 200):
        return cls(success=True, message=message, status=status, data=data)

    # Hatalı yanıtlar için Factory Method
    @classmethod
    def error_response(cls, message: str, errors: List[str] = None, status: int = 500):
        return cls(success=False, message=message, status=status, errors=errors)

# --- SADECE VERİYİ TAŞIYAN SAF DTO'LAR ---
# (Artık içlerinde success veya message barındırmıyorlar, sadece saf veri)

class VerificationDto(BaseModel):
    distance: float
    threshold: float
    is_genuine: bool
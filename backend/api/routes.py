from fastapi import APIRouter, File, UploadFile
from fastapi.responses import JSONResponse
from core.schemas import ApiResponse, VerificationDto
from services.signature_service import signature_service

router = APIRouter(prefix="/api/v1")

# DEĞİŞİKLİK 1: response_model artık saf DTO değil, ApiResponse ile sarmalanmış DTO
@router.post("/verify-signature/", response_model=ApiResponse[VerificationDto])
async def verify_signature(
    reference_img: UploadFile = File(...), 
    query_img: UploadFile = File(...)
):
    try:
        # 1. Dosyaları oku
        ref_bytes = await reference_img.read()
        query_bytes = await query_img.read()

        if not ref_bytes or not query_bytes:
            error_resp = ApiResponse.error_response(
                message="File is empty",
                errors=["Both reference and query images must be provided."],
                status=400
            )
            return JSONResponse(status_code=error_resp.status, content=error_resp.model_dump())

        # 2. İşi Servis'e devret (Servis sadece saf veriyi döner)
        result = signature_service.verify(ref_bytes, query_bytes)

        # DEĞİŞİKLİK 2: Başarılı sonucu Factory Method ile sarmalayarak dönüyoruz
        return ApiResponse.success_response(
            data=result,
            message="Signature verified successfully." if result.is_genuine else "Signature verification failed."
        )

    except Exception as e:
        error_resp = ApiResponse.error_response(
            message="An unexpected error occurred on the server.",
            errors=[str(e)]
        )
        # Hata durumunda HTTP statü kodunu (500) korumak için JSONResponse kullanıyoruz
        return JSONResponse(status_code=error_resp.status, content=error_resp.model_dump())
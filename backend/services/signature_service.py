import torch
import torch.nn.functional as F
from torchvision import transforms
from PIL import Image
import io
import sys
import os

# ml_model klasöründeki model.py'yi okuyabilmek için yolu ekliyoruz
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'ml_model'))
from core.schemas import VerificationDto
from model import SignatureSiameseNetwork

class SignatureService:
    def __init__(self):
        # Sınıf çağrıldığında modeli cihaz belleğine sadece SADECE 1 KERE yükler
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model = SignatureSiameseNetwork(embedding_dim=128, dropout_rate=0.5)
        
        model_path = os.path.join("ml_model", "siamese_signature_model.pth")
        self.model.load_state_dict(torch.load(model_path, map_location=self.device))
        self.model.to(self.device)
        self.model.eval()

        self.preprocess = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.Grayscale(num_output_channels=3),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
        ])
        
        self.THRESHOLD = 0.15

    def _process_image(self, image_bytes: bytes):
        """Yardımcı fonksiyon: Byteları tensöre çevirir"""
        image = Image.open(io.BytesIO(image_bytes)).convert('RGB')
        return self.preprocess(image).unsqueeze(0).to(self.device)

    def verify(self, ref_bytes: bytes, query_bytes: bytes) -> dict:
        """Controller'ın çağıracağı asıl iş fonksiyonu"""
        img1_tensor = self._process_image(ref_bytes)
        img2_tensor = self._process_image(query_bytes)

        with torch.no_grad():
            out1, out2 = self.model(img1_tensor, img2_tensor)
            distance = F.pairwise_distance(out1, out2).item()

        is_genuine = bool(distance < self.THRESHOLD)

        # Direkt dict dönüyoruz, Controller bunu DTO'ya çevirecek
        return VerificationDto(
            distance=round(distance, 4),
            threshold=self.THRESHOLD,
            is_genuine=is_genuine
        )

# Servisi başlatıp bir değişkene atıyoruz (Tüm API boyunca tek instance çalışacak)
signature_service = SignatureService()
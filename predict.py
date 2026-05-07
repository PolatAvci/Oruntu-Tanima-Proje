import torch
import torch.nn.functional as F
from torchvision import transforms
from PIL import Image
import matplotlib.pyplot as plt

# Kendi model sınıfını içe aktar
from model import SignatureSiameseNetwork

def load_model(model_path, device):
    """Eğitilmiş modeli yükler ve değerlendirme moduna alır."""
    # Modelin mimarisini oluştur (eğitimdeki ile aynı parametreler olmalı)
    model = SignatureSiameseNetwork(embedding_dim=128, dropout_rate=0.5)
    
    # Ağırlıkları yükle
    model.load_state_dict(torch.load(model_path, map_location=device))
    model.to(device)
    
    # Çok Önemli: Modeli test moduna al (Dropout ve BatchNorm davranışını değiştirir)
    model.eval() 
    return model

def preprocess_image(image_path):
    """Görüntüyü ağın beklediği formata dönüştürür (Val Transform ile aynı)."""
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.Grayscale(num_output_channels=3), 
        transforms.ToTensor(), 
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    
    image = Image.open(image_path).convert('RGB')
    image_tensor = transform(image)
    
    # Modele verebilmek için Batch boyutu ekle: (3, 224, 224) -> (1, 3, 224, 224)
    image_tensor = image_tensor.unsqueeze(0) 
    return image, image_tensor

def predict_signature(img1_path, img2_path, model, device, threshold=0.5):
    """İki imza arasındaki mesafeyi ölçer ve tahmin yapar."""
    # Resimleri yükle ve işle
    img1_pil, img1_tensor = preprocess_image(img1_path)
    img2_pil, img2_tensor = preprocess_image(img2_path)
    
    img1_tensor = img1_tensor.to(device)
    img2_tensor = img2_tensor.to(device)
    
    # Tahmin (Inference)
    with torch.no_grad(): # Gradyan hesaplamayı kapat (hızlandırır ve bellek tasarrufu sağlar)
        output1, output2 = model(img1_tensor, img2_tensor)
        
        # Öklid mesafesini hesapla
        distance = F.pairwise_distance(output1, output2).item()
        
    # Eşiğe göre karar ver
    is_genuine = distance < threshold
    
    # Görselleştirme
    show_prediction(img1_pil, img2_pil, distance, is_genuine, threshold)
    
    return distance, is_genuine

def show_prediction(img1, img2, distance, is_genuine, threshold):
    """Sonuçları ekranda gösterir."""
    fig, axes = plt.subplots(1, 2, figsize=(10, 5))
    
    axes[0].imshow(img1)
    axes[0].set_title("Referans İmza")
    axes[0].axis("off")
    
    axes[1].imshow(img2)
    axes[1].set_title("Sorgulanan İmza")
    axes[1].axis("off")
    
    result_text = "ORİJİNAL (AYNI KİŞİ)" if is_genuine else "SAHTE (FARKLI/TAKLİT)"
    color = "green" if is_genuine else "red"
    
    plt.suptitle(f"Sonuç: {result_text}\n"
                 f"Mesafe: {distance:.4f} (Eşik: {threshold})", 
                 fontsize=14, color=color, fontweight='bold')
    
    plt.tight_layout()
    plt.show()

# ==========================================
# TEST BÖLÜMÜ
# ==========================================
if __name__ == "__main__":
    # 1. Cihazı Belirle (Eğitimdeki gibi Apple Silicon desteği)
    device = torch.device("cuda" if torch.cuda.is_available() else "mps" if torch.backends.mps.is_available() else "cpu")
    print(f"Test için kullanılan donanım: {device}")
    
    # 2. Modeli Yükle
    MODEL_PATH = "siamese_signature_model.pth"
    model = load_model(MODEL_PATH, device)
    
    # 3. Test Edilecek Resim Yolları (BURAYI KENDİ RESİMLERİNE GÖRE DEĞİŞTİR)
    # Test setinden hiç görülmemiş bir yazarın iki imzasını seçebilirsin
    reference_image = "dataset/processed_signatures/val/org/original_6_1.png" 
    query_image = "dataset/processed_signatures/val/forg/forgeries_6_5.png" 
    
    print("Tahmin yapılıyor...")
    # threshold eğitimde kullanılan 0.15 olarak bırakıldı
    dist, result = predict_signature(reference_image, query_image, model, device, threshold=0.15)
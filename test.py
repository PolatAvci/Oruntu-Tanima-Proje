import os
import torch
import torch.nn.functional as F
from torchvision import transforms
from torch.utils.data import DataLoader
from PIL import Image
import matplotlib.pyplot as plt
import numpy as np
from sklearn.metrics import confusion_matrix, accuracy_score, precision_score, recall_score, f1_score

# Kendi modülleriniz
from model import SignatureSiameseNetwork
from dataset import SignatureDataset
from transforms import PadToSquare

# 1. Ayarlar ve Cihaz Seçimi
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "mps" if torch.backends.mps.is_available() else "cpu")
MODEL_WEIGHTS = "siamese_signature_model.pth"
TEST_DATASET_ROOT = r"C:\Users\polat\OneDrive\Masaüstü\real_test" # org ve forg klasörlerini içeren ana dizin
THRESHOLD = 0.25 # Eğitimde kullandığınız eşik değeri

print(f"Test için kullanılan donanım: {DEVICE}")

# 2. Test Ön İşlem (Eğitimdeki val_transform ile tamamen aynı olmalı)
test_transform = transforms.Compose([
    PadToSquare(fill=255),
    transforms.Resize((224, 224)),
    transforms.Grayscale(num_output_channels=3), 
    transforms.ToTensor(), 
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

# 3. Modeli Yükleme
def load_model():
    model = SignatureSiameseNetwork(embedding_dim=128, dropout_rate=0.5, freeze_backbone=False)
    if os.path.exists(MODEL_WEIGHTS):
        model.load_state_dict(torch.load(MODEL_WEIGHTS, map_location=DEVICE))
        print("Model ağırlıkları başarıyla yüklendi!")
    else:
        raise FileNotFoundError(f"HATA: {MODEL_WEIGHTS} bulunamadı! Lütfen model yolunu kontrol edin.")
    
    model.to(DEVICE)
    model.eval() # Modeli test moduna alıyoruz
    return model

# 4. Tüm Veri Setini Değerlendirme Fonksiyonu
def evaluate_dataset(model, dataset_root):
    print("\n--- TOPLU VERİ SETİ DEĞERLENDİRMESİ BAŞLIYOR ---")
    test_dataset = SignatureDataset(root_dir=dataset_root, transform=test_transform, is_train=False)
    test_dataloader = DataLoader(test_dataset, batch_size=32, shuffle=False)
    
    all_labels = []
    all_preds = []
    all_distances = []

    with torch.no_grad():
        for img1, img2, label in test_dataloader:
            img1, img2 = img1.to(DEVICE), img2.to(DEVICE)
            
            output1, output2 = model(img1, img2)
            distances = F.pairwise_distance(output1, output2)
            predictions = (distances < THRESHOLD).float()
            
            all_labels.extend(label.cpu().numpy())
            all_preds.extend(predictions.cpu().numpy())
            all_distances.extend(distances.cpu().numpy())

    # Metrikleri Hesaplama
    acc = accuracy_score(all_labels, all_preds)
    precision = precision_score(all_labels, all_preds, zero_division=0)
    recall = recall_score(all_labels, all_preds, zero_division=0)
    f1 = f1_score(all_labels, all_preds, zero_division=0)
    
    # FAR (False Acceptance Rate) ve FRR (False Rejection Rate) Hesaplama
    tn, fp, fn, tp = confusion_matrix(all_labels, all_preds).ravel()
    far = fp / (fp + tn) if (fp + tn) > 0 else 0.0 # Sahte bir imzayı gerçek sanma oranı
    frr = fn / (fn + tp) if (fn + tp) > 0 else 0.0 # Gerçek bir imzayı sahte sanma oranı

    print(f"Toplam Test Çifti Sayısı: {len(all_labels)}")
    print(f"Doğruluk (Accuracy): %{acc * 100:.2f}")
    print(f"Hassasiyet (Precision): %{precision * 100:.2f}")
    print(f"Duyarlılık (Recall): %{recall * 100:.2f}")
    print(f"F1-Skoru: %{f1 * 100:.2f}")
    print(f"FAR (Yanlış Kabul Oranı - Sahteyi onaylama): %{far * 100:.2f}")
    print(f"FRR (Yanlış Red Oranı - Gerçeği reddetme): %{frr * 100:.2f}")

# 5. İki Spesifik İmzayı Kıyaslama Fonksiyonu
def verify_signature_pair(model, img_path_1, img_path_2):
    print(f"\n--- TEKLİ İMZA KIYASLAMASI ---")
    print(f"Referans: {os.path.basename(img_path_1)}")
    print(f"Test Edilen: {os.path.basename(img_path_2)}")
    
    img1_pil = Image.open(img_path_1).convert('RGB')
    img2_pil = Image.open(img_path_2).convert('RGB')
    
    # Tensor'e çevir ve batch boyutu ekle (1, C, H, W)
    img1_tensor = test_transform(img1_pil).unsqueeze(0).to(DEVICE)
    img2_tensor = test_transform(img2_pil).unsqueeze(0).to(DEVICE)
    
    with torch.no_grad():
        out1, out2 = model(img1_tensor, img2_tensor)
        distance = F.pairwise_distance(out1, out2).item()
        
    is_match = distance < THRESHOLD
    result_text = "EŞLEŞTİ (GERÇEK İMZA)" if is_match else "EŞLEŞMEDİ (SAHTE İMZA)"
    color = 'green' if is_match else 'red'
    
    print(f"Hesaplanan Mesafe: {distance:.4f} (Eşik: {THRESHOLD})")
    print(f"Sonuç: {result_text}")
    
    # Görselleştirme
    fig, axes = plt.subplots(1, 2, figsize=(10, 5))
    axes[0].imshow(img1_pil)
    axes[0].set_title("Referans İmza")
    axes[0].axis('off')
    
    axes[1].imshow(img2_pil)
    axes[1].set_title(f"Test Edilen\nMesafe: {distance:.4f}\n{result_text}")
    axes[1].axis('off')
    
    # Başlığın rengini sonuca göre ayarla
    plt.suptitle(f"Siyam Ağı Kararı", color=color, fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    # 1. Modeli Yükle
    model = load_model()
    
    # 2. Tüm Klasörü Toplu Test Et (Metrikleri Gör)
    # Eğer veri setiniz belirtilen ROOT dizininde org ve forg klasörlerine sahipse:
    try:
        evaluate_dataset(model, TEST_DATASET_ROOT)
    except Exception as e:
         print(f"Toplu test sırasında bir hata oluştu (Klasör yollarını kontrol edin): {e}")

    # 3. İki spesifik görseli manuel test etme örneği
    # Kendi görsellerinizin yollarını buraya yazarak spesifik test yapabilirsiniz:
    # org_img_path = os.path.join(TEST_DATASET_ROOT, "org", "org_1_1.jpeg")
    # forg_img_path = os.path.join(TEST_DATASET_ROOT, "forg", "forg_1_1.jpeg")
    # 
    # if os.path.exists(org_img_path) and os.path.exists(forg_img_path):
    #     verify_signature_pair(model, org_img_path, forg_img_path)
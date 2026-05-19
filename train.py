import os
import random
import numpy as np
import torch
import torch.nn.functional as F # Mesafe hesaplamak için eklendi
import matplotlib.pyplot as plt
from torch.utils.data import DataLoader
from torchvision import transforms

from contrastive_loss import ContrastiveLoss
from model import SignatureSiameseNetwork
from dataset import SignatureDataset
from transforms import PadToSquare

def set_deterministic_seed(seed=42):
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed(seed)
        torch.cuda.manual_seed_all(seed)
    elif torch.backends.mps.is_available():
        torch.mps.manual_seed(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False

set_deterministic_seed(22)

# 1. Cihaz Ayarı
device = torch.device("cuda" if torch.cuda.is_available() else "mps" if torch.backends.mps.is_available() else "cpu")
print(f"Eğitim için kullanılan donanım: {device}")

# 2. Ön İşleme
train_transform = transforms.Compose([
    PadToSquare(fill=255),
    transforms.Resize((224, 224)),
    transforms.Grayscale(num_output_channels=3), 
    transforms.RandomRotation(degrees=10),       
    transforms.RandomAffine(degrees=0, translate=(0.05, 0.05), shear=5, fill=255), 
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

val_transform = transforms.Compose([
    PadToSquare(fill=255),
    transforms.Resize((224, 224)),
    transforms.Grayscale(num_output_channels=3), 
    transforms.ToTensor(), 
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

# 3. Dataset ve Dataloader Tanımları
train_dataset = SignatureDataset(root_dir="dataset/processed_signatures/train", transform=train_transform, is_train=True)
val_dataset = SignatureDataset(root_dir="dataset/processed_signatures/val", transform=val_transform, is_train=False)

train_dataloader = DataLoader(train_dataset, batch_size=32, shuffle=True)
val_dataloader = DataLoader(val_dataset, batch_size=32, shuffle=False)

# 4. Model, Loss ve Optimizer (PHASE 1: Dondurulmuş Başlangıç)
# ResNet'i dondurarak başlatıyoruz ki FC katmanımız adapte olsun
model = SignatureSiameseNetwork(embedding_dim=128, dropout_rate=0.5, freeze_backbone=True).to(device)
criterion = ContrastiveLoss(margin=1.0)

# ÖNEMLİ: Optimizer'a sadece requires_grad=True olan (yani bizim FC) parametreleri veriyoruz
optimizer = torch.optim.Adam(filter(lambda p: p.requires_grad, model.parameters()), lr=0.0001)

# --- METRİKLER İÇİN LİSTELER ---
history_train_loss, history_val_loss = [], []
history_train_acc, history_val_acc = [], []

# 5. Eğitim Döngüsü
num_epochs = 50
base_seed = 42
threshold = 0.15
phase2_start_epoch = 10

for epoch in range(num_epochs):
    current_epoch_seed = base_seed + epoch
    train_dataset.pairs = train_dataset.generate_pairs(epoch_seed=current_epoch_seed)

    # PHASE 2 GEÇİŞİ (Unfreeze - Tüm Ağı Açma)
    if epoch == phase2_start_epoch:
        print(f"\n--- PHASE 2: FINE TUNING BAŞLIYOR (Epoch {epoch+1}) ---")
        model.unfreeze_resnet() # ResNet'in kilitlerini açıyoruz
        
        # Tüm ağ açıldığı için Catastrophic Forgetting'i engellemek adına 
        # Learning Rate'i çok düşük bir seviyeye (1e-5) çekip Optimizer'ı yeniliyoruz
        optimizer = torch.optim.Adam(model.parameters(), lr=0.00001) 

    
    # --- EĞİTİM AŞAMASI (TRAIN) ---
    model.train() 
    train_loss = 0.0
    train_correct = 0 # Doğru tahminleri saymak için
    train_total = 0   # Toplam tahminleri saymak için
    
    for i, data in enumerate(train_dataloader, 0):
        img1, img2, label = data
        img1, img2, label = img1.to(device), img2.to(device), label.to(device)
        
        optimizer.zero_grad()
        output1, output2 = model(img1, img2)
        loss = criterion(output1, output2, label)
        loss.backward()
        optimizer.step()
        
        train_loss += loss.item()
        
        # Accuracy Hesaplama (Train)
        with torch.no_grad():
            distances = F.pairwise_distance(output1, output2)
            # Mesafe threshold'dan küçükse 1 (Gerçek), büyükse 0 (Sahte) tahmin et
            predictions = (distances < threshold).float()
            train_correct += (predictions == label).sum().item()
            train_total += label.size(0)
            
    avg_train_loss = train_loss / len(train_dataloader)
    avg_train_acc = train_correct / train_total
    
    history_train_loss.append(avg_train_loss)
    history_train_acc.append(avg_train_acc)
    
    # --- DOĞRULAMA AŞAMASI (VALIDATION) ---
    model.eval() 
    val_loss = 0.0
    val_correct = 0
    val_total = 0
    
    with torch.no_grad():
        for i, data in enumerate(val_dataloader, 0):
            img1, img2, label = data
            img1, img2, label = img1.to(device), img2.to(device), label.to(device)
            
            output1, output2 = model(img1, img2)
            loss = criterion(output1, output2, label)
            val_loss += loss.item()
            
            # Accuracy Hesaplama (Val)
            distances = F.pairwise_distance(output1, output2)
            predictions = (distances < threshold).float()
            val_correct += (predictions == label).sum().item()
            val_total += label.size(0)
            
    avg_val_loss = val_loss / len(val_dataloader)
    avg_val_acc = val_correct / val_total
    
    history_val_loss.append(avg_val_loss)
    history_val_acc.append(avg_val_acc)
    
    print(f"Epoch [{epoch+1}/{num_epochs}] | "
          f"Train Loss: {avg_train_loss:.4f} - Acc: {avg_train_acc:.4f} | "
          f"Val Loss: {avg_val_loss:.4f} - Acc: {avg_val_acc:.4f}")

print("Eğitim Tamamlandı! Model ağırlıkları kaydediliyor...")
torch.save(model.state_dict(), "siamese_signature_model.pth")
print("Ağırlıklar başarıyla kaydedildi!")

# --- GRAFİK ÇİZİMİ (Loss ve Accuracy Yan Yana) ---
print("Grafikler oluşturuluyor...")
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))

# 1. Grafik: Loss Eğrisi
ax1.plot(range(1, num_epochs + 1), history_train_loss, label='Train Loss', color='blue', marker='o')
ax1.plot(range(1, num_epochs + 1), history_val_loss, label='Validation Loss', color='red', marker='x')
ax1.set_title('Eğitim ve Doğrulama Loss Değerleri', fontsize=14)
ax1.set_xlabel('Epoch', fontsize=12)
ax1.set_ylabel('Contrastive Loss', fontsize=12)
ax1.legend(fontsize=12)
ax1.grid(True, linestyle='--', alpha=0.7)

# 2. Grafik: Accuracy Eğrisi
ax2.plot(range(1, num_epochs + 1), history_train_acc, label='Train Accuracy', color='green', marker='o')
ax2.plot(range(1, num_epochs + 1), history_val_acc, label='Validation Accuracy', color='orange', marker='x')
ax2.set_title('Eğitim ve Doğrulama Accuracy (%)', fontsize=14)
ax2.set_xlabel('Epoch', fontsize=12)
ax2.set_ylabel('Accuracy', fontsize=12)
ax2.legend(fontsize=12)
ax2.grid(True, linestyle='--', alpha=0.7)

plt.tight_layout()
plt.savefig('train_val_metrics.png', dpi=300, bbox_inches='tight')
print("Grafikler 'train_val_metrics.png' olarak başarıyla kaydedildi!")
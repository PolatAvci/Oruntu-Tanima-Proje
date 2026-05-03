import os
import random
import numpy as np
import torch
import matplotlib.pyplot as plt # Grafikler için eklendi
from torch.utils.data import DataLoader
from torchvision import transforms

from contrastive_loss import ContrastiveLoss
from model import SignatureSiameseNetwork
from dataset import SignatureDataset


def set_deterministic_seed(seed=42):
    # Python, NumPy ve PyTorch tohumlarını sabitle
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    
    # Donanım hızlandırıcı tohumlarını sabitle
    if torch.cuda.is_available():
        torch.cuda.manual_seed(seed)
        torch.cuda.manual_seed_all(seed) # Multi-GPU için
    elif torch.backends.mps.is_available():
        torch.mps.manual_seed(seed)
        
    # PyTorch'un arka plan optimizasyonlarını deterministik yap
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False

set_deterministic_seed(22)

# 1. Cihaz Ayarı
device = torch.device(
    "cuda" if torch.cuda.is_available() else 
    "mps" if torch.backends.mps.is_available() else 
    "cpu"
)
print(f"Eğitim için kullanılan donanım: {device}")

# 2. Ön İşleme
train_transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.Grayscale(num_output_channels=3), 
    transforms.RandomRotation(degrees=10),       
    transforms.RandomAffine(degrees=0, translate=(0.05, 0.05)), 
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

val_transform = transforms.Compose([
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

# 4. Model, Loss ve Optimizer
model = SignatureSiameseNetwork(embedding_dim=128, dropout_rate=0.5).to(device)
criterion = ContrastiveLoss(margin=1.0)
optimizer = torch.optim.Adam(model.parameters(), lr=0.0001)

# --- GRAFİK İÇİN LİSTELER (YENİ EKLENDİ) ---
history_train_loss = []
history_val_loss = []

# 5. Eğitim Döngüsü
num_epochs = 20
base_seed = 42

for epoch in range(num_epochs):

    # Epoch numarasına göre yeni bir seed belirliyoruz.
    # Örn: 1. Epoch -> seed 43, 2. Epoch -> seed 44...
    current_epoch_seed = base_seed + epoch
    train_dataset.pairs = train_dataset.generate_pairs(epoch_seed=current_epoch_seed)
    
    # --- EĞİTİM AŞAMASI (TRAIN) ---
    model.train() 
    train_loss = 0.0
    
    for i, data in enumerate(train_dataloader, 0):
        img1, img2, label = data
        img1, img2, label = img1.to(device), img2.to(device), label.to(device)
        
        optimizer.zero_grad()
        output1, output2 = model(img1, img2)
        loss = criterion(output1, output2, label)
        loss.backward()
        optimizer.step()
        
        train_loss += loss.item()
        
    avg_train_loss = train_loss / len(train_dataloader)
    history_train_loss.append(avg_train_loss) # Listeye kaydet
    
    # --- DOĞRULAMA AŞAMASI (VALIDATION) ---
    model.eval() 
    val_loss = 0.0
    
    with torch.no_grad():
        for i, data in enumerate(val_dataloader, 0):
            img1, img2, label = data
            img1, img2, label = img1.to(device), img2.to(device), label.to(device)
            
            output1, output2 = model(img1, img2)
            loss = criterion(output1, output2, label)
            val_loss += loss.item()
            
    avg_val_loss = val_loss / len(val_dataloader)
    history_val_loss.append(avg_val_loss) # Listeye kaydet
    
    print(f"Epoch [{epoch+1}/{num_epochs}] | Train Loss: {avg_train_loss:.4f} | Val Loss: {avg_val_loss:.4f}")

print("Eğitim Tamamlandı! Model ağırlıkları kaydediliyor...")

# --- MODELİ KAYDETME ---
model_save_path = "siamese_signature_model.pth"
torch.save(model.state_dict(), model_save_path)
print(f"Eğitilmiş model ağırlıkları '{model_save_path}' dosyasına başarıyla kaydedildi!")


# --- GRAFİK ÇİZİMİ VE KAYDETME (YENİ EKLENDİ) ---
print("Train - Validation grafiği oluşturuluyor...")

plt.figure(figsize=(10, 6)) # Grafiğin boyutunu belirle
plt.plot(range(1, num_epochs + 1), history_train_loss, label='Train Loss', color='blue', marker='o')
plt.plot(range(1, num_epochs + 1), history_val_loss, label='Validation Loss', color='red', marker='x')

plt.title('Eğitim ve Doğrulama Kayıp (Loss) Eğrisi', fontsize=14)
plt.xlabel('Epoch', fontsize=12)
plt.ylabel('Contrastive Loss', fontsize=12)
plt.legend(fontsize=12)
plt.grid(True, linestyle='--', alpha=0.7)

# Grafiği çalışma dizinine kaydet
plt.savefig('train_val_loss.png', dpi=300, bbox_inches='tight')
print("Grafik 'train_val_loss.png' olarak başarıyla kaydedildi!")
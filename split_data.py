import os
import shutil
import random

# Yolları belirle
SOURCE_DIR = "dataset/raw_signatures"
TARGET_DIR = "dataset/processed_signatures"
ORG_DIR = "org"
FORG_DIR = "forg"

# Sabit seed (Bölünme oranları her çalıştırmada aynı kalsın diye)
random.seed(22)

def create_dirs(base_path):
    """Gerekli klasör yapısını oluşturur."""
    for split in ['train', 'val', 'test']:
        os.makedirs(os.path.join(base_path, split, ORG_DIR), exist_ok=True)
        os.makedirs(os.path.join(base_path, split, FORG_DIR), exist_ok=True)

def get_writer_ids(source_dir):
    """Dosya isimlerinden eşsiz yazar ID'lerini toplar."""
    org_files = os.listdir(os.path.join(source_dir, ORG_DIR))
    # 'original_10_1.png' -> split('_') -> ['original', '10', '1.png'] -> indeks 1 (Yazar ID)
    writer_ids = set([f.split('_')[1] for f in org_files if f.lower().endswith(('.png', '.tif'))])
    return list(writer_ids)

def copy_files_by_writer(writer_ids, split_name):
    """Belirtilen yazarların Orijinal ve Sahte imzalarını ilgili klasöre kopyalar."""
    for wid in writer_ids:
        # 1. Orijinal dosyaları bul ve kopyala
        org_source = os.path.join(SOURCE_DIR, ORG_DIR)
        
        # Sadece resim dosyalarını ve adında "_" olanları işleme al
        org_files = [f for f in os.listdir(org_source) 
                     if f.lower().endswith(('.png', '.tif', '.jpg', '.jpeg')) 
                     and '_' in f 
                     and f.split('_')[1] == wid]
        
        for f in org_files:
            shutil.copy2(os.path.join(org_source, f), 
                         os.path.join(TARGET_DIR, split_name, ORG_DIR, f))
            
        # 2. Sahte dosyaları bul ve kopyala (Eğer varsa)
        forg_source = os.path.join(SOURCE_DIR, FORG_DIR)
        if os.path.exists(forg_source):
            # Aynı güvenliği buraya da ekliyoruz
            forg_files = [f for f in os.listdir(forg_source) 
                          if f.lower().endswith(('.png', '.tif', '.jpg', '.jpeg')) 
                          and '_' in f 
                          and f.split('_')[1] == wid]
            
            for f in forg_files:
                shutil.copy2(os.path.join(forg_source, f), 
                             os.path.join(TARGET_DIR, split_name, FORG_DIR, f))

# 1. Hedef klasörleri yarat
create_dirs(TARGET_DIR)

# 2. Yazar ID'lerini al ve karıştır
writers = get_writer_ids(SOURCE_DIR)
random.shuffle(writers)

total_writers = len(writers)
print(f"Toplam Yazar (Sınıf) Sayısı: {total_writers}")

# 3. %70 Train, %15 Val, %15 Test olarak indeksleri belirle
train_idx = int(total_writers * 0.70)
val_idx = int(total_writers * 0.85)

train_writers = writers[:train_idx]
val_writers = writers[train_idx:val_idx]
test_writers = writers[val_idx:]

print(f"Train setine {len(train_writers)} yazar aktarılıyor...")
copy_files_by_writer(train_writers, 'train')

print(f"Val setine {len(val_writers)} yazar aktarılıyor...")
copy_files_by_writer(val_writers, 'val')

print(f"Test setine {len(test_writers)} yazar aktarılıyor...")
copy_files_by_writer(test_writers, 'test')

print(f"İşlem Tamamlandı! Veriler {TARGET_DIR} klasörüne başarıyla bölündü.")
import os
import random
from PIL import Image
import torch
from torch.utils.data import Dataset
from torchvision import transforms

class SignatureDataset(Dataset):
    def __init__(self, root_dir, transform=None):
        self.root_dir = root_dir
        self.transform = transform
        
        self.org_dir = os.path.join(root_dir, 'org')
        self.forg_dir = os.path.join(root_dir, 'forg')
        
        # os.listdir sırası işletim sistemine göre değişebilir, mutlaka sorted() kullanılmalı
        self.org_files = sorted([f for f in os.listdir(self.org_dir) if f.lower().endswith(('.png', '.tif'))])
        self.forg_files = sorted([f for f in os.listdir(self.forg_dir) if f.lower().endswith(('.png', '.tif'))])
        
        self.writers = self._group_by_writer()
        
        # Sabit (deterministik) çiftleri sınıf oluşturulurken bir kere tanımlıyoruz
        self.pairs = self._generate_static_pairs()

    def _group_by_writer(self):
        writers = {}
        for f in self.org_files:
            writer_id = f.split('_')[1] 
            if writer_id not in writers:
                writers[writer_id] = {'org': [], 'forg': []}
            writers[writer_id]['org'].append(os.path.join(self.org_dir, f))
            
        for f in self.forg_files:
            writer_id = f.split('_')[1]
            if writer_id in writers:
                writers[writer_id]['forg'].append(os.path.join(self.forg_dir, f))
                
        return writers

    def _generate_static_pairs(self):
        pairs = []
        # Sabit bir seed atayarak validasyon/test kümelerinin her çalıştırmada aynı kalmasını sağlıyoruz
        rng = random.Random(22) 
        
        for writer_id, data in self.writers.items():
            orgs = data['org']
            forgs = data['forg']
            
            # Her orijinal imza için 1 pozitif, 1 negatif çift oluşturuyoruz
            for img1_path in orgs:
                # 1. Pozitif Çift Oluşturma
                img2_org_path = rng.choice(orgs)
                pairs.append((img1_path, img2_org_path, 1.0)) # 1.0: Gerçek
                
                # 2. Negatif Çift Oluşturma (Eğer yazarın sahte imzası varsa)
                if forgs:
                    img2_forg_path = rng.choice(forgs)
                    pairs.append((img1_path, img2_forg_path, 0.0)) # 0.0: Sahte
                    
        return pairs

    def __len__(self):
        return len(self.pairs) 

    def __getitem__(self, idx):
        # Doğrudan pre-calculated listeden index ile çekiyoruz
        img1_path, img2_path, label_val = self.pairs[idx]
        
        label = torch.tensor(label_val, dtype=torch.float32)
        
        img1 = Image.open(img1_path).convert('RGB')
        img2 = Image.open(img2_path).convert('RGB')
        
        if self.transform:
            img1 = self.transform(img1)
            img2 = self.transform(img2)
            
        return img1, img2, label
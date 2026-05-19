import os
import random
from PIL import Image
import torch
from torch.utils.data import Dataset
from torchvision import transforms

class SignatureDataset(Dataset):
    # is_train parametresini ekliyoruz. Eğitim ve Validasyon davranışını ayırmak için.
    def __init__(self, root_dir, transform=None, is_train=True): 
        self.root_dir = root_dir
        self.transform = transform
        self.is_train = is_train
        
        self.org_dir = os.path.join(root_dir, 'org')
        self.forg_dir = os.path.join(root_dir, 'forg')
        
        self.org_files = sorted([f for f in os.listdir(self.org_dir) if f.lower().endswith(('.png', '.tif', '.jpg', '.jpeg'))])
        self.forg_files = sorted([f for f in os.listdir(self.forg_dir) if f.lower().endswith(('.png', '.tif', '.jpg', '.jpeg'))])
        
        self.writers = self._group_by_writer()
        
        # Validasyon/Test setleri SADECE BİR KERE ve SABİT oluşturulur.
        # Eğitim seti ise epoch başında yeniden oluşturulacağı için başlangıçta boş kalabilir veya ilk epoch için oluşturulabilir.
        if not self.is_train:
             # Validasyon hep aynı seed ile oluşturulsun ki adil kıyaslama yapılsın
             self.pairs = self.generate_pairs(epoch_seed=22) 
        else:
             # Eğitim için ilk epoch çiftlerini oluştur
             self.pairs = self.generate_pairs(epoch_seed=0)

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

    def generate_pairs(self, epoch_seed): 
        pairs = []
        rng = random.Random(epoch_seed) 
        
        all_writer_ids = list(self.writers.keys())
        
        for writer_id, data in self.writers.items():
            orgs = data['org']
            forgs = data['forg']
            
            for img1_path in orgs:
                # ==========================================
                # 1. POZİTİF ÇİFT (Sürekli Eklenecek - Label 1.0)
                # ==========================================
                available_orgs = [img for img in orgs if img != img1_path]
                img2_org_path = rng.choice(available_orgs) if available_orgs else img1_path
                pairs.append((img1_path, img2_org_path, 1.0)) 
                
                # ==========================================
                # 2. NEGATİF ÇİFT (Sadece 1 Tane Eklenecek - Label 0.0)
                # ==========================================
                negative_options = []
                
                if forgs:
                    negative_options.append('forgery') # Kendi sahtesi
                if len(all_writer_ids) > 1:
                    negative_options.append('unrelated') # Başkasının gerçeği
                    
                if negative_options:
                    # %50 ihtimalle sahte, %50 ihtimalle alakasız seç
                    selected_negative_type = rng.choice(negative_options)
                    
                    if selected_negative_type == 'forgery':
                        img2_neg_path = rng.choice(forgs)
                        pairs.append((img1_path, img2_neg_path, 0.0))
                        
                    elif selected_negative_type == 'unrelated':
                        other_writers = [w for w in all_writer_ids if w != writer_id]
                        random_other_writer_id = rng.choice(other_writers)
                        other_writer_orgs = self.writers[random_other_writer_id]['org']
                        
                        if other_writer_orgs:
                            img2_neg_path = rng.choice(other_writer_orgs)
                            pairs.append((img1_path, img2_neg_path, 0.0))
                        else:
                            # Çok nadir bir edge-case (seçilen yazarın org imzası yoksa)
                            # Çökmeyi engellemek için kendi sahtesini koy
                            if forgs:
                                pairs.append((img1_path, rng.choice(forgs), 0.0))
                        
        return pairs
    
    def __len__(self):
        return len(self.pairs) 

    def __getitem__(self, idx):
        img1_path, img2_path, label_val = self.pairs[idx]
        label = torch.tensor(label_val, dtype=torch.float32)
        
        img1 = Image.open(img1_path).convert('RGB')
        img2 = Image.open(img2_path).convert('RGB')
        
        if self.transform:
            img1 = self.transform(img1)
            img2 = self.transform(img2)
            
        return img1, img2, label
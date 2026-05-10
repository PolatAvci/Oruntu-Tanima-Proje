import torch
import torch.nn as nn
import torchvision.models as models

class SignatureSiameseNetwork(nn.Module):
    def __init__(self, embedding_dim=128, dropout_rate=0.5):
        super(SignatureSiameseNetwork, self).__init__()
        
        # 1. Aşama: Güçlü bir CNN Omurgası (ResNet-50)
        # ImageNet üzerinde önceden eğitilmiş ağırlıkları kullanıyoruz.
        # Bu, modelin temel çizgi ve şekil algısını halihazırda bilmesini sağlar.
        resnet = models.resnet50(weights=models.ResNet50_Weights.IMAGENET1K_V1)
        
        # ResNet'in son katmanı (1000 sınıflı FC katmanı) iptal ediyoruz
        # Çünkü biz sınıflandırma değil, özellik vektörü (embedding) istiyoruz.
        self.backbone = nn.Sequential(*list(resnet.children())[:-1])
        
        # 2. Aşama: İmza Doğrulama için Özel Tam Bağlı (Fully Connected) Katmanlar
        # ResNet-50'den çıkan özellik haritasını alıp (2048 boyutlu), 
        # bizim belirlediğimiz daha küçük ve yoğun bir vektöre (embedding_dim) sıkıştırıyoruz.
        self.fc = nn.Sequential(
            nn.Flatten(),
            nn.Linear(2048, 512),
            nn.BatchNorm1d(512), # Eğitim stabilitesini artırır
            nn.ReLU(inplace=True),
            nn.Dropout(p=dropout_rate), # Aşırı öğrenmeyi (Overfitting) engellemek için
            
            nn.Linear(512, 256),
            nn.BatchNorm1d(256),
            nn.ReLU(inplace=True),
            
            # Çıktı vektörü (Örn: 128 boyutlu)
            # Bu vektör, o imzanın matematiksel "parmak izi" olacak.
            nn.Linear(256, embedding_dim) 
        )

    def forward_once(self, x):
        # Tek bir imzayı ağdan geçirip embedding (parmak izi) vektörünü çıkarma
        features = self.backbone(x)
        embeddings = self.fc(features)
        
        # Vektörleri L2 normalize etmek, mesafeleri (Euclidean) hesaplarken modeli çok daha kararlı hale getirir.
        embeddings = nn.functional.normalize(embeddings, p=2, dim=1) 
        return embeddings

    def forward(self, input1, input2):
        # Siyam Ağının mantığı: İki farklı girdiyi (referans ve sorgulanan imza)
        # AYNI ağdan geçiriyoruz (ağırlıklar ortaktır).
        embedding1 = self.forward_once(input1)
        embedding2 = self.forward_once(input2)
        
        # Model her iki imzanın da 128 boyutlu parmak izini döndürür.
        return embedding1, embedding2
import torch
import torch.nn as nn
import torchvision.models as models

class SignatureSiameseNetwork(nn.Module):
    # freeze_backbone=False: Varsayılan olarak tüm ağ açık (Tahmin/Fine-Tuning için hazır)
    def __init__(self, embedding_dim=128, dropout_rate=0.5, freeze_backbone=False):
        super(SignatureSiameseNetwork, self).__init__()
        
        # 1. Aşama: Güçlü bir CNN Omurgası (ResNet-50)
        resnet = models.resnet50(weights=models.ResNet50_Weights.IMAGENET1K_V1)
        self.backbone = nn.Sequential(*list(resnet.children())[:-1])
        
        # Eğer parametre True verildiyse başlangıçta ResNet'i dondur (Phase 1 eğitimi için)
        if freeze_backbone:
            self.freeze_resnet()
        
        # 2. Aşama: İmza Doğrulama için Özel Tam Bağlı (Fully Connected) Katmanlar
        self.fc = nn.Sequential(
            nn.Flatten(),
            nn.Linear(2048, 512),
            nn.BatchNorm1d(512),
            nn.ReLU(inplace=True),
            nn.Dropout(p=dropout_rate),
            
            nn.Linear(512, 256),
            nn.BatchNorm1d(256),
            nn.ReLU(inplace=True),
            
            nn.Linear(256, embedding_dim) 
        )

    def freeze_resnet(self):
        """Omurga (ResNet) katmanlarının ağırlıklarını dondurur."""
        for param in self.backbone.parameters():
            param.requires_grad = False
            
    def unfreeze_resnet(self):
        """Omurga (ResNet) katmanlarının kilitlerini açar (Fine-tuning için)."""
        for param in self.backbone.parameters():
            param.requires_grad = True

    def forward_once(self, x):
        features = self.backbone(x)
        embeddings = self.fc(features)
        embeddings = nn.functional.normalize(embeddings, p=2, dim=1) 
        return embeddings

    def forward(self, input1, input2):
        embedding1 = self.forward_once(input1)
        embedding2 = self.forward_once(input2)
        return embedding1, embedding2
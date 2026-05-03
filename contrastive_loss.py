import torch
from torch import nn
import torch.nn.functional as F

class ContrastiveLoss(nn.Module):
    def __init__(self, margin=1.0):
        super(ContrastiveLoss, self).__init__()
        self.margin = margin

    def forward(self, output1, output2, label):
        # İki imza vektörü arasındaki Öklid mesafesini hesapla
        euclidean_distance = F.pairwise_distance(output1, output2, keepdim=True)
        
        # Etiketlerimizi tensör boyutuna uygun hale getirelim
        label = label.view(-1, 1)
        
        # Formül: 
        # Eğer Orijinal-Orijinal ise (label=1): Mesafeyi sıfıra yaklaştır
        # Eğer Orijinal-Sahte ise (label=0): Mesafeyi en az 'margin' (1.0) kadar uzaklaştır
        loss_contrastive = torch.mean((label) * torch.pow(euclidean_distance, 2) +
                                      (1 - label) * torch.pow(torch.clamp(self.margin - euclidean_distance, min=0.0), 2))
        return loss_contrastive
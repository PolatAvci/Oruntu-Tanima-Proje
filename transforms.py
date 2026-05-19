import torchvision.transforms.functional as TF

class PadToSquare:
    """
    Dikdörtgen görüntüleri oranlarını bozmadan, eksik kısımları 
    belirlenen bir renkle (varsayılan: beyaz) doldurarak kareye tamamlar.
    """
    def __init__(self, fill=255):
        self.fill = fill

    def __call__(self, img):
        # img bir PIL Image nesnesidir
        w, h = img.size
        max_dim = max(w, h)
        
        # Sol, Üst, Sağ, Alt padding miktarlarını hesapla
        padding_left = (max_dim - w) // 2
        padding_right = max_dim - w - padding_left
        padding_top = (max_dim - h) // 2
        padding_bottom = max_dim - h - padding_top
        
        padding = (padding_left, padding_top, padding_right, padding_bottom)
        
        # Resmi belirlenen renkle (fill) kareye tamamla
        return TF.pad(img, padding, fill=self.fill, padding_mode='constant')
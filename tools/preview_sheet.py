import json,os
from PIL import Image, ImageDraw, ImageFont
WA='app/android/app/src/main/assets/stickers'; meta=json.load(open(WA+'/contents.json'))
F=ImageFont.truetype('/usr/share/fonts/truetype/sand-box/google/Anton/Anton-Regular.ttf',34)
cols=10; cell=170; rows=sum((len(p['stickers'])+cols-1)//cols for p in meta['sticker_packs'])
H=rows*cell+len(meta['sticker_packs'])*80+20
W=Image.new('RGB',(cols*cell+20,H),(28,30,40)); d=ImageDraw.Draw(W); y=10
for p in meta['sticker_packs']:
    t=Image.open(f"{WA}/{p['identifier']}/tray.png").convert('RGBA'); W.paste(t.resize((64,64)),(14,y+6),t.resize((64,64)))
    d.text((90,y+12),f"Pack {p['identifier']}: {p['name']} ({len(p['stickers'])} stickers)",font=F,fill=(255,214,40)); y+=80
    for i,s in enumerate(p['stickers']):
        im=Image.open(f"{WA}/{p['identifier']}/{s['image_file']}").convert('RGBA').resize((160,160),Image.LANCZOS)
        W.paste(im,(10+(i%cols)*cell,y+(i//cols)*cell),im)
    y+=((len(p['stickers'])+cols-1)//cols)*cell
W.save('dist/stickers-preview.png',optimize=True); print(W.size, os.path.getsize('dist/stickers-preview.png'))

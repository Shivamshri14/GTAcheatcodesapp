from PIL import Image, ImageFilter
def outline(img,w=26,col=(255,255,255,255)):
    a=img.split()[3].filter(ImageFilter.MaxFilter(w*2+1 if w*2+1<=61 else 61))
    if w*2+1>61:
        for _ in range((w*2+1)//61): a=a.filter(ImageFilter.MaxFilter(31))
    base=Image.new('RGBA',img.size,col); base.putalpha(a)
    sh=Image.new('RGBA',img.size,(0,0,0,110)); sh.putalpha(a.point(lambda v:int(v*0.45)))
    out=Image.new('RGBA',img.size,(0,0,0,0)); out.alpha_composite(sh,(8,12)); out.alpha_composite(base); out.alpha_composite(img); return out

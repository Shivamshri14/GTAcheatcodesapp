# Original, GTA-meme-inspired sticker art drawn with PIL + SIL OFL fonts (Anton, Bangers, Archivo Black).
# No Rockstar artwork, logos, characters or Pricedown font.
import os, math, json
from PIL import Image, ImageDraw, ImageFont, ImageFilter
G='/usr/share/fonts/truetype/sand-box/google/'
ANTON=G+'Anton/Anton-Regular.ttf'; BANG=G+'Bangers/Bangers-Regular.ttf'
ARCH=G+'Archivo Black/ArchivoBlack-Regular.ttf' if os.path.exists(G+'Archivo Black/ArchivoBlack-Regular.ttf') else ANTON
S=1024  # draw at 2x
OUT=os.path.join(os.path.dirname(__file__),'..','app','android','app','src','main','assets','stickers','1')
PREV=os.path.join(os.path.dirname(__file__),'..','app','assets','stickers','1')
os.makedirs(OUT,exist_ok=True); os.makedirs(PREV,exist_ok=True)
def F(p,s): return ImageFont.truetype(p,s)
def canvas(): return Image.new('RGBA',(S,S),(0,0,0,0))
def outline(img,w=26,col=(255,255,255,255)):
    a=img.split()[3].filter(ImageFilter.MaxFilter(w*2+1 if w*2+1<=61 else 61))
    if w*2+1>61:
        for _ in range((w*2+1)//61): a=a.filter(ImageFilter.MaxFilter(31))
    base=Image.new('RGBA',img.size,col); base.putalpha(a)
    sh=Image.new('RGBA',img.size,(0,0,0,110)); sh.putalpha(a.point(lambda v:int(v*0.45)))
    out=Image.new('RGBA',img.size,(0,0,0,0)); out.alpha_composite(sh,(8,12)); out.alpha_composite(base); out.alpha_composite(img); return out
def text_fit(d,txt,font_path,maxw,start):
    s=start
    while s>20:
        f=F(font_path,s); b=d.textbbox((0,0),txt,font=f)
        if b[2]-b[0]<=maxw: return f,b
        s-=4
    return f,b
def ctext(d,txt,cy,font_path,size,fill,maxw=900,stroke=0,sc=(0,0,0),spacing=0):
    f,b=text_fit(d,txt,font_path,maxw,size); w=b[2]-b[0]; h=b[3]-b[1]
    d.text(((S-w)/2-b[0],cy-h/2-b[1]),txt,font=f,fill=fill,stroke_width=stroke,stroke_fill=sc); return h
def star(d,cx,cy,r,fill,ol=None,ow=0):
    pts=[]
    for i in range(10):
        a=-math.pi/2+i*math.pi/5; rr=r if i%2==0 else r*0.45
        pts.append((cx+rr*math.cos(a),cy+rr*math.sin(a)))
    d.polygon(pts,fill=fill,outline=ol,width=ow)
def save(img,name,do_outline=True):
    if do_outline: img=outline(img)
    im=img.resize((512,512),Image.LANCZOS)
    q=90
    while True:
        p=os.path.join(OUT,name+'.webp'); im.save(p,'WEBP',quality=q,method=6)
        if os.path.getsize(p)<95_000 or q<40: break
        q-=8
    im.resize((256,256),Image.LANCZOS).save(os.path.join(PREV,name+'.webp'),'WEBP',quality=80)
    return name+'.webp'
files=[]
# 1 WASTED banner
im=canvas(); d=ImageDraw.Draw(im)
d.rounded_rectangle((30,370,S-30,654),30,fill=(20,20,20,225))
ctext(d,'wasted',512,ANTON,300,(200,20,20),maxw=820,stroke=10,sc=(0,0,0))
files.append((save(im,'01_wasted'),['💀','😵']))
# 2 BUSTED
im=canvas(); d=ImageDraw.Draw(im)
d.rounded_rectangle((30,370,S-30,654),30,fill=(20,20,20,225))
ctext(d,'busted',512,ANTON,300,(40,120,255),maxw=820,stroke=10,sc=(0,0,0))
files.append((save(im,'02_busted'),['🚓','😬']))
# 3 MISSION PASSED / RESPECT +
im=canvas(); d=ImageDraw.Draw(im)
d.rounded_rectangle((40,300,S-40,724),40,fill=(15,15,15,225))
ctext(d,'mission passed!',430,ANTON,150,(245,190,40),maxw=880,stroke=8)
ctext(d,'respect +',610,ANTON,130,(255,255,255),maxw=700,stroke=8)
files.append((save(im,'03_mission_passed'),['🏆','✅']))
# 4 MISSION FAILED
im=canvas(); d=ImageDraw.Draw(im)
d.rounded_rectangle((40,360,S-40,664),40,fill=(15,15,15,225))
ctext(d,'mission failed',512,ANTON,160,(220,30,30),maxw=880,stroke=8)
files.append((save(im,'04_mission_failed'),['❌','😩']))
# 5 Wanted stars
im=canvas(); d=ImageDraw.Draw(im)
d.rounded_rectangle((30,330,S-30,700),50,fill=(15,15,15,220))
for i in range(5):
    star(d,140+i*186,470,82,(255,255,255),(0,0,0),6)
ctext(d,'WANTED',630,ANTON,110,(255,210,60),maxw=600,stroke=6)
files.append((save(im,'05_wanted_stars'),['⭐','🚨']))
# 6 Ah sh*t here we go again
im=canvas(); d=ImageDraw.Draw(im)
d.rounded_rectangle((40,250,S-40,774),50,fill=(255,255,255,240))
ctext(d,'AH SH*T,',380,BANG,190,(25,25,25),maxw=860)
ctext(d,'HERE WE GO',560,BANG,170,(40,160,70),maxw=880)
ctext(d,'AGAIN',700,BANG,150,(25,25,25),maxw=700)
files.append((save(im,'06_here_we_go_again'),['🙄','😤']))
# 7 Follow the damn train
im=canvas(); d=ImageDraw.Draw(im)
d.rounded_rectangle((40,200,S-40,824),50,fill=(250,240,210,245))
ctext(d,'ALL WE HAD',320,BANG,150,(30,30,30),maxw=860)
ctext(d,'TO DO WAS',460,BANG,150,(30,30,30),maxw=860)
ctext(d,'FOLLOW THE',600,BANG,150,(200,40,40),maxw=860)
ctext(d,'DAMN TRAIN!',740,BANG,150,(200,40,40),maxw=880)
files.append((save(im,'07_follow_the_train'),['🚂','🤦']))
# 8 HERE WE GO
im=canvas(); d=ImageDraw.Draw(im)
ctext(d,'HERE',380,BANG,300,(255,200,40),maxw=900,stroke=14,sc=(20,20,20))
ctext(d,'WE GO!',660,BANG,300,(255,80,160),maxw=920,stroke=14,sc=(20,20,20))
files.append((save(im,'08_here_we_go'),['🔥','😎']))
# 9 Cash stack
im=canvas(); d=ImageDraw.Draw(im)
for k in range(6):
    y=640-k*70; x0=170+(k%2)*24
    d.rounded_rectangle((x0,y,x0+640,y+150),18,fill=(46,140,70),outline=(15,70,30),width=8)
    d.rounded_rectangle((x0+40,y+25,x0+600,y+125),12,outline=(170,230,170),width=6)
    d.ellipse((x0+270,y+35,x0+370,y+115),fill=(120,200,130),outline=(15,70,30),width=5)
    d.text((x0+302,y+42),'$',font=F(ANTON,64),fill=(15,70,30))
d.rectangle((420,250,520,830),fill=(240,220,120),outline=(130,100,20),width=6)
ctext(d,'+$250,000',150,ANTON,150,(90,230,110),maxw=820,stroke=10,sc=(10,40,15))
files.append((save(im,'09_cash_stack'),['💰','🤑']))
# 10 Sports car
im=canvas(); d=ImageDraw.Draw(im)
body=[(90,640),(130,540),(300,500),(420,400),(650,390),(800,480),(930,520),(950,620),(920,660),(110,670)]
d.polygon(body,fill=(235,40,60),outline=(20,20,20),width=10)
d.polygon([(330,505),(440,420),(630,415),(740,490)],fill=(140,210,255),outline=(20,20,20),width=8)
d.line((530,418,530,500),fill=(20,20,20),width=8)
for cx in (260,770):
    d.ellipse((cx-95,560,cx+95,750),fill=(25,25,25)); d.ellipse((cx-50,605,cx+50,705),fill=(200,200,210))
d.polygon([(880,540),(945,545),(940,580),(885,575)],fill=(255,240,150))
for i in range(3): d.line((20,520+i*55,110-i*20,520+i*55),fill=(255,255,255),width=12)
ctext(d,'VROOM!',240,BANG,200,(255,210,40),maxw=700,stroke=12,sc=(20,20,20))
files.append((save(im,'10_sports_car'),['🏎️','💨']))
# 11 Police siren
im=canvas(); d=ImageDraw.Draw(im)
d.rounded_rectangle((250,600,774,720),30,fill=(60,60,70),outline=(20,20,20),width=8)
d.pieslice((300,300,724,820),180,360,fill=(230,40,40),outline=(20,20,20),width=10)
d.pieslice((420,380,604,620),180,360,fill=(255,140,140))
for a in range(-60,61,30):
    r=math.radians(a-90); x1=512+300*math.cos(r); y1=470+300*math.sin(r); x2=512+420*math.cos(r); y2=470+420*math.sin(r)
    d.line((x1,y1,x2,y2),fill=(255,220,60),width=22)
ctext(d,'WEE-WOO!',860,BANG,150,(40,120,255),maxw=700,stroke=10,sc=(255,255,255))
files.append((save(im,'11_police_siren'),['🚨','👮']))
# 12 Neon city + palm trees
im=canvas(); d=ImageDraw.Draw(im)
d.ellipse((112,112,912,912),fill=(40,10,70))
for i,c in enumerate([(255,90,160),(255,130,120),(255,180,90),(255,220,80)]):
    d.pieslice((262+i*0,300+i*0,762,800),180,360,fill=c) if i==0 else None
for k in range(5): d.rectangle((262,500+k*40-18,762,500+k*40-8),fill=(40,10,70))
for (x,h) in [(330,220),(420,300),(560,260),(640,200)]: d.rectangle((x,760-h,x+70,760),fill=(20,0,40),outline=(0,240,255),width=5)
def palm(x,y,s,flip=1):
    tx,ty=x+40*flip*s,y-330*s
    d.line([(x,y),(x+15*flip*s,y-170*s),(tx,ty)],fill=(15,5,30),width=int(30*s))
    for ang in (200,235,270,305,340,160):
        r=math.radians(ang); ex,ey=tx+190*s*math.cos(r),ty+190*s*math.sin(r)*0.8
        mx,my=(tx+ex)/2,(ty+ey)/2-40*s
        nx,ny=-(ey-ty),(ex-tx); L=math.hypot(nx,ny) or 1; nx,ny=nx/L*28*s,ny/L*28*s
        d.polygon([(tx,ty),(mx+nx,my+ny),(ex,ey+30*s),(mx-nx,my-ny)],fill=(15,5,30))
palm(230,770,1.15); palm(800,770,1.05,-1)
d.rectangle((112,760,912,800),fill=(0,240,255))
ctext(d,'NEON NIGHTS',920,ANTON,120,(255,90,200),maxw=760,stroke=8,sc=(20,0,40))
files.append((save(im,'12_neon_city'),['🌴','🌆']))
# 13 Cheat activated
im=canvas(); d=ImageDraw.Draw(im)
d.rounded_rectangle((40,360,S-40,664),30,fill=(10,10,10,230),outline=(0,255,140),width=10)
ctext(d,'CHEAT ACTIVATED',512,ANTON,140,(0,255,140),maxw=860)
files.append((save(im,'13_cheat_activated'),['🎮','✨']))
# 14 HESOYAM
im=canvas(); d=ImageDraw.Draw(im)
ctext(d,'HESOYAM',430,ANTON,260,(255,255,255),maxw=900,stroke=14,sc=(20,20,20))
ctext(d,'health + armor + cash',640,ANTON,90,(255,210,60),maxw=860,stroke=8,sc=(20,20,20))
files.append((save(im,'14_hesoyam'),['❤️','💪']))
# 15 Respect +
im=canvas(); d=ImageDraw.Draw(im)
d.ellipse((160,160,864,864),fill=(245,190,40),outline=(20,20,20),width=14)
ctext(d,'RESPECT',430,ANTON,170,(20,20,20),maxw=560)
ctext(d,'+ 100',620,ANTON,150,(255,255,255),maxw=520,stroke=10,sc=(20,20,20))
files.append((save(im,'15_respect_plus'),['🙌','💯']))
# 16 Five-star chaos
im=canvas(); d=ImageDraw.Draw(im)
for i,(x,y,r) in enumerate([(512,330,190),(250,600,150),(774,600,150),(380,830,110),(644,830,110)]):
    star(d,x,y,r,(255,215,40),(20,20,20),10)
files.append((save(im,'16_five_stars'),['⭐','🌟']))
# 17 Respawned at hospital
im=canvas(); d=ImageDraw.Draw(im)
d.rounded_rectangle((60,280,S-60,744),40,fill=(255,255,255,245),outline=(220,30,30),width=12)
d.rectangle((462,330,562,520),fill=(220,30,30)); d.rectangle((417,375,607,475),fill=(220,30,30))
ctext(d,'RESPAWNED',610,ANTON,130,(25,25,25),maxw=780)
ctext(d,'-$100',700,ANTON,80,(220,30,30),maxw=500)
files.append((save(im,'17_respawned'),['🏥','🤕']))
# 18 Speedometer / Nitro
im=canvas(); d=ImageDraw.Draw(im)
ctext(d,'NITRO',512,BANG,330,(60,200,255),maxw=900,stroke=16,sc=(10,20,60))
for i in range(4): d.line((80,700+i*40,940-i*120,700+i*40),fill=(255,120,40),width=16)
files.append((save(im,'18_nitro'),['⚡','🚀']))
# tray icon 96x96 png (<50KB): stars on dark round
t=Image.new('RGBA',(384,384),(0,0,0,0)); d=ImageDraw.Draw(t)
d.ellipse((8,8,376,376),fill=(255,80,120)); star(d,192,200,150,(255,230,60),(20,20,20),10)
t=t.resize((96,96),Image.LANCZOS); t.save(os.path.join(OUT,'tray.png'),optimize=True)
json.dump([[f,e] for f,e in files],open(os.path.join(os.path.dirname(__file__),'..','art','pack1_memes.json'),'w'),ensure_ascii=False)
for f,_ in files: print(f, os.path.getsize(os.path.join(OUT,f)))

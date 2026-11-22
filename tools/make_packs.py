# Builds sticker packs 2 & 3 (original AI-assisted cartoon characters/objects, cut from art/gen sheets)
# + adds object stickers to pack 1, writes WhatsApp contents.json (3 packs) and the in-app preview index.
import os, json, sys
from PIL import Image, ImageDraw, ImageFont
sys.path.insert(0, os.path.dirname(__file__))
H=os.path.dirname(__file__); R=os.path.join(H,'..','art')
WA=os.path.join(H,'..','app','android','app','src','main','assets','stickers')
PV=os.path.join(H,'..','app','assets','stickers')
G='/usr/share/fonts/truetype/sand-box/google/'; BANG=G+'Bangers/Bangers-Regular.ttf'
S=1024
from make_stickers_lib import outline
def font_fit(d,txt,maxw,start):
    s=start
    while s>40:
        f=ImageFont.truetype(BANG,s); b=d.textbbox((0,0),txt,font=f,stroke_width=14)
        if b[2]-b[0]<=maxw: return f
        s-=6
    return f
def wrap(txt):
    if len(txt)<=14: return [txt]
    w=txt.split(); best=None
    for i in range(1,len(w)):
        a,b=' '.join(w[:i]),' '.join(w[i:]); m=max(len(a),len(b))
        if best is None or m<best[0]: best=(m,[a,b])
    return best[1]
BUST={'crying','laughing','facepalm','shrug','thumbs_up','eye_roll','shocked','chefs_kiss'}
def make(src, caption, color):
    art=Image.open(os.path.join(R,'cut',src+'.png')).convert('RGBA')
    if src in BUST:
        art=art.crop((0,0,art.width,int(art.height*0.58))); art=art.crop(art.getbbox())
    im=Image.new('RGBA',(S,S),(0,0,0,0)); d=ImageDraw.Draw(im)
    lines=wrap(caption) if caption else []
    cap_h={0:0,1:200,2:330}[len(lines)]
    box_w,box_h=900,(S-60-cap_h-30)
    sc=min(box_w/art.width,box_h/art.height); art=art.resize((int(art.width*sc),int(art.height*sc)),Image.LANCZOS)
    top=40+(box_h-art.height)//2 if not lines else 40+(box_h-art.height)
    im.alpha_composite(art,((S-art.width)//2,max(30,top)))
    y=S-50-cap_h
    for ln in lines:
        f=font_fit(d,ln,940,190 if len(lines)==1 else 160); b=d.textbbox((0,0),ln,font=f,stroke_width=14)
        d.text(((S-(b[2]-b[0]))/2-b[0], y-b[1]),ln,font=f,fill=color,stroke_width=14,stroke_fill=(15,15,20))
        y+=(b[3]-b[1])+12
    return outline(im,w=22)
def save(img,pack,name):
    os.makedirs(os.path.join(WA,pack),exist_ok=True); os.makedirs(os.path.join(PV,pack),exist_ok=True)
    im=img.resize((512,512),Image.LANCZOS); p=os.path.join(WA,pack,name+'.webp'); q=88
    while True:
        im.save(p,'WEBP',quality=q,method=6)
        if os.path.getsize(p)<95_000 or q<30: break
        q-=6
    im.resize((256,256),Image.LANCZOS).save(os.path.join(PV,pack,name+'.webp'),'WEBP',quality=80)
    return name+'.webp'
def tray(src,pack,crop_frac=0.42,bg=(255,200,40)):
    os.makedirs(os.path.join(WA,pack),exist_ok=True); os.makedirs(os.path.join(PV,pack),exist_ok=True)
    art=Image.open(os.path.join(R,'cut',src+'.png')).convert('RGBA')
    h=int(art.height*crop_frac); head=art.crop((0,0,art.width,h)); bb=head.getbbox(); head=head.crop(bb)
    t=Image.new('RGBA',(384,384),(0,0,0,0)); d=ImageDraw.Draw(t); d.ellipse((6,6,378,378),fill=bg+(255,),outline=(20,20,20),width=10)
    sc=min(300/head.width,300/head.height); head=head.resize((int(head.width*sc),int(head.height*sc)),Image.LANCZOS)
    mask=Image.new('L',(384,384),0); ImageDraw.Draw(mask).ellipse((16,16,368,368),fill=255)
    layer=Image.new('RGBA',(384,384),(0,0,0,0)); layer.alpha_composite(head,((384-head.width)//2,384-head.height-14 if head.height<330 else 40))
    a=layer.split()[3]; from PIL import ImageChops; layer.putalpha(ImageChops.multiply(a,mask)); t.alpha_composite(layer)
    t=t.resize((96,96),Image.LANCZOS); t.save(os.path.join(WA,pack,'tray.png'),optimize=True)
    t.save(os.path.join(PV,pack,'tray.png'))
Y=(255,214,40); W_=(255,255,255); P=(255,90,160); C=(80,220,255); GR=(120,240,120); O=(255,140,40)
pack1=[tuple(x) for x in json.load(open(os.path.join(R,'pack1_memes.json')))]
P1=[('o_sportscar','NEW WHIP',Y,['🚗','😎']),('o_police_car','COPS!',C,['🚓','😱']),('o_cash','PAYDAY',GR,['💵','🤑']),
    ('o_money_bag','EZ MONEY',GR,['💰','😏']),('o_chain','DRIP',Y,['💎','😎']),('o_aviators','STAY COOL',P,['😎']),
    ('o_chopper',"LET'S RIDE",O,['🏍','🤘']),('o_armor','FULL ARMOR',GR,['🛡','💪']),('o_fire_can','BURN IT',O,['🔥','😈']),
    ('o_bat','BATTER UP',Y,['😠','👊'])]
P2=[('bandana',"WHAT'S UP HOMIE",GR,['👋','😎']),('cop','PULL OVER!',C,['🚓','👮']),('biker','RIDE OR DIE',O,['🏍','🤘']),
    ('hustler','MONEY TALKS',Y,['💰','🤑']),('shades_girl','NOT MY PROBLEM',P,['💅','😎']),('getaway','GET IN, LOSER',W_,['🚗','😉']),
    ('bat_thug','SAY THAT AGAIN',O,['😠','👊']),('white_suit','WE GOT A DEAL?',W_,['💼','🤝']),('hacker','HACKING...',GR,['💻','😈']),
    ('racer_girl','CATCH ME IF U CAN',Y,['🏁','✌']),('swat','FREEZE!',C,['🛑','👮']),('tourist',"I'M JUST VISITING",Y,['📸','😱']),
    ('grandma','RESPECT YOUR ELDERS',P,['👵','😡']),('gym_bro','DO YOU EVEN LIFT?',O,['💪','😤']),('lady_cop','BACKUP REQUESTED',C,['📻','👮']),
    ('mob_boss','WE NEED TO TALK',W_,['😏','🎩']),('mechanic','I CAN FIX IT',Y,['🔧','😁']),('guard','I SAW NOTHING',W_,['🔦','😰']),
    ('cash_call','CALL MY ACCOUNTANT',GR,['💵','📞']),('old_hustler','BACK IN MY DAY...',Y,['👴','😌']),('bouncer','NOT ON THE LIST',O,['🚫','💪']),
    ('donut_cop','ON BREAK',P,['🍩','☕']),('pizza','DELIVERY!',O,['🍕','🛵']),('dj','DROP THE BEAT',C,['🎧','🔥']),
    ('skater','WHATEVER',GR,['🛹','😜']),('paramedic','MEDIC!!',W_,['🚑','😰']),('robber','BRB, HEIST',Y,['💰','🏃']),
    ('dancer','VIBING',P,['💃','🕺']),('burger_guy','CHEAT DAY',O,['🍔','😋']),('gossip',"GIRL, YOU WON'T BELIEVE IT",P,['📱','😲'])]
P3=[('crying','MISSION FAILED',W_,['😭','💔']),('laughing','LMAO WASTED',Y,['😂','👉']),('facepalm','BRUH.',W_,['🤦','😑']),
    ('shrug','IDK MAN',C,['🤷','😕']),('thumbs_up','RESPECT +',GR,['👍','😎']),('eye_roll','UGH, WHATEVER',P,['🙄','💅']),
    ('sleeping','AFK',C,['😴','💤']),('cash_throne','LIVING RICH',Y,['👑','💰']),('shocked','SAY WHAT?!',O,['😱','😮']),
    ('chefs_kiss','PERFECTION',P,['😘','👌']),('o_heli','AIR SUPPORT',C,['🚁']),('o_skull','DEAD INSIDE',O,['💀']),
    ('o_heart','LOVE YA',P,['❤','👑']),('o_trophy','WINNER',Y,['🏆','🥇']),('o_burger','FOOD RUN',O,['🍔','🍟']),
    ('o_bomb','TICK TOCK',O,['💣','⏰']),('o_boat','SEE YA!',C,['🚤','👋']),('o_taxi','TAXI!',Y,['🚕','🙋'])]
packs=[('1','Cheat Codes Memes',pack1+[(save(make(s,c,col),'1',f'{19+i:02d}_{s[2:]}'),e) for i,(s,c,col,e) in enumerate(P1)])]
tray('hustler','2',bg=(140,80,255)); tray('laughing','3',bg=(255,90,160))
packs.append(('2','Cheat Codes Street Crew',[(save(make(s,c,col),'2',f'{i+1:02d}_{s}'),e) for i,(s,c,col,e) in enumerate(P2)]))
packs.append(('3','Cheat Codes Reactions',[(save(make(s,c,col),'3',f'{i+1:02d}_{s}'),e) for i,(s,c,col,e) in enumerate(P3)]))
# pack-1 tray: copy to preview
Image.open(os.path.join(WA,'1','tray.png')).save(os.path.join(PV,'1','tray.png'))
meta={'android_play_store_link':'','ios_app_store_link':'','sticker_packs':[{
  'identifier':pid,'name':name,'publisher':'Saksham Srivastava','tray_image_file':'tray.png','image_data_version':'2',
  'avoid_cache':False,'publisher_email':'','publisher_website':'','privacy_policy_website':'','license_agreement_website':'',
  'animated_sticker_pack':False,'stickers':[{'image_file':f,'emojis':e} for f,e in files]} for pid,name,files in packs]}
json.dump(meta,open(os.path.join(WA,'contents.json'),'w'),indent=1,ensure_ascii=False)
json.dump([{'id':pid,'name':name,'stickers':[f for f,_ in files]} for pid,name,files in packs],open(os.path.join(PV,'index.json'),'w'),ensure_ascii=False)
mx=0
for pid,name,files in packs:
    for f,_ in files: mx=max(mx,os.path.getsize(os.path.join(WA,pid,f)))
    print(pid,name,len(files),'tray',os.path.getsize(os.path.join(WA,pid,'tray.png')))
print('max sticker bytes',mx)

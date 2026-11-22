# Cuts the AI-generated original character/object sheets (art/gen/*.jpg, white bg) into transparent PNGs.
import os, numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage as ndi
R=os.path.join(os.path.dirname(__file__),'..','art'); OUT=os.path.join(R,'cut'); os.makedirs(OUT,exist_ok=True)
def cut(sheet, grid, names):
    im=Image.open(os.path.join(R,'gen',sheet)).convert('RGB'); a=np.asarray(im).astype(int)
    near_white=(a.min(axis=2)>228)&((a.max(axis=2)-a.min(axis=2))<22)
    # background = near-white connected to border
    lab,_=ndi.label(near_white); border=set(np.unique(np.concatenate([lab[0],lab[-1],lab[:,0],lab[:,-1]])))-{0}
    bg=np.isin(lab,list(border))
    fg=~bg; fg=ndi.binary_opening(fg,iterations=1)
    lab2,n=ndi.label(ndi.binary_dilation(fg,iterations=4))
    H,W=fg.shape; cw,ch=W/grid[0],H/grid[1]
    sizes=ndi.sum(np.ones_like(lab2),lab2,range(1,n+1))
    cells={}
    for i in range(1,n+1):
        if sizes[i-1]<60: continue
        ys,xs=np.nonzero(lab2==i); cy,cx=ys.mean(),xs.mean()
        key=(int(cy//ch),int(cx//cw)); cells.setdefault(key,[]).append(i)
    for key,ids in list(cells.items()):
        for i in list(ids):
            ys,xs=np.nonzero(lab2==i)
            if xs.max()-xs.min()>cw*1.15:
                m=(lab2==i)&fg; col=m.sum(axis=0); x0=int(xs.min()+cw*0.6); x1=int(xs.max()-cw*0.6)
                cut_x=x0+int(np.argmin(col[x0:x1])); n+=1; lab2[(lab2==i)&(np.arange(W)[None,:]>cut_x)]=n
                ids.remove(i)
                for j in (i,n):
                    yy,xx=np.nonzero(lab2==j); cells.setdefault((int(yy.mean()//ch),int(xx.mean()//cw)),[]).append(j)
    alpha=Image.fromarray((fg*255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.8))
    rgba=im.copy(); rgba.putalpha(alpha)
    k=0
    for r in range(grid[1]):
        for c in range(grid[0]):
            ids=cells.get((r,c)); name=names[k]; k+=1
            if not ids or not name: continue
            m=np.isin(lab2,ids)&fg
            ys,xs=np.nonzero(m); box=(xs.min(),ys.min(),xs.max()+1,ys.max()+1)
            piece=rgba.copy(); pa=np.asarray(piece.split()[3]).copy(); pa[~ndi.binary_dilation(m,iterations=2)]=0
            piece.putalpha(Image.fromarray(pa)); piece.crop(box).save(os.path.join(OUT,name+'.png'))
C=lambda s,n: cut(s,(2,2),n)
C('chars1.jpg',['bandana','cop','biker','hustler'])
C('chars2.jpg',['shades_girl','getaway','bat_thug','white_suit'])
C('chars3.jpg',['hacker','racer_girl','swat','tourist'])
C('chars4.jpg',['grandma','gym_bro','lady_cop','mob_boss'])
C('chars5.jpg',['crying','laughing','facepalm','shrug'])
C('chars6.jpg',['robber','thumbs_up','eye_roll','sleeping'])
C('chars7.jpg',['dancer','burger_guy','gossip','cash_throne'])
C('chars8.jpg',['paramedic','pizza','dj','skater'])
C('chars9.jpg',['mechanic','guard','cash_call','old_hustler'])
C('chars10.jpg',['shocked','chefs_kiss','bouncer','donut_cop'])
cut('objects1.jpg',(3,3),['o_sportscar','o_police_car','o_cash','o_money_bag','o_chain','o_aviators','o_chopper','o_armor','o_fire_can'])
cut('objects2.jpg',(3,3),['o_taxi','o_heli','o_bat','o_skull','o_heart','o_trophy','o_burger','o_bomb','o_boat'])
print(len(os.listdir(OUT)))

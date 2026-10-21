#!/usr/bin/env python3
"""Makes a launcher icon for each color theme from the lavender one: the
mark recolored to the theme's primary, on a 10% tint of it. Run from the
repo root after changing the icon:  python3 tool/make_theme_icons.py
Needs Pillow (pip install pillow)."""
import colorsys, os
from PIL import Image
R='android/app/src/main/res'
themes={'rose':0xFF5D9E,'papaya':0xFF6B4A,'ocean':0x3B82F6,'matcha':0x65A30D,'lilac':0xA855F7,'sky':0x0EA5E9,'honey':0xF59E0B,'slate':0x475569,'mint':0x0D9488,'cherry':0xE11D48,'forest':0x15803D,'midnight':0x1E3A8A,'mocha':0x8B5E3C,'roseGold':0xB76E79}
def rgb(h): return ((h>>16)&255,(h>>8)&255,h&255)
def hsv(c): return colorsys.rgb_to_hsv(*[x/255 for x in c])
base=hsv(rgb(0x7C5CFC))
def snake(n): return ''.join('_'+ch.lower() if ch.isupper() else ch for ch in n)
# Where a pixel sits on the original gradient: purple (0) to teal (1).
PURPLE, TEAL = 0.70, 0.47
for name,col in themes.items():
    h1,s1,v1=hsv(rgb(col))
    # The gradient's far end: a neighbouring hue, a little lighter. Greens
    # lean toward teal (toward yellow they look neon).
    h2=(h1+0.09)%1.0 if 0.12<h1<0.45 else (h1-0.09)%1.0
    for d in ['mdpi','hdpi','xhdpi','xxhdpi','xxxhdpi']:
        im=Image.open(f'{R}/mipmap-{d}/ic_launcher_foreground.png').convert('RGBA')
        px=im.load(); W,H=im.size
        for y in range(H):
            for x in range(W):
                r,g,b,a=px[x,y]
                if a==0: continue
                ph,ps,pv=colorsys.rgb_to_hsv(r/255,g/255,b/255)
                if ps<0.08:  # whites/greys (the ring, the glow) stay
                    continue
                t=min(max((PURPLE-ph)/(PURPLE-TEAL),0.0),1.0)
                dh=((h2-h1+0.5)%1.0)-0.5
                nh=(h1+dh*t)%1.0
                ns=min(1.0,s1*min(1.0,ps/base[1])*0.92)
                nv=min(1.0,pv*(0.55+0.45*v1)*(1+0.10*t))
                nr,ng,nb=colorsys.hsv_to_rgb(nh,ns,nv)
                px[x,y]=(round(nr*255),round(ng*255),round(nb*255),a)
        im.save(f'{R}/mipmap-{d}/ic_launcher_foreground_{snake(name)}.png',optimize=True)
    pr,pg,pb=rgb(col)
    bg='#%02X%02X%02X'%tuple(round(255*0.9+c*0.1) for c in (pr,pg,pb))
    open(f'{R}/drawable/ic_launcher_background_{snake(name)}.xml','w').write(f'''<?xml version="1.0" encoding="utf-8"?>
<!-- The {name} theme's icon background (generated; see tool/make_theme_icons.py). -->
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="{bg}" />
</shape>
''')
    open(f'{R}/mipmap-anydpi-v26/ic_launcher_{snake(name)}.xml','w').write(f'''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background_{snake(name)}" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground_{snake(name)}" />
    <monochrome android:drawable="@mipmap/ic_launcher_monochrome" />
</adaptive-icon>
''')
    print(name, bg)

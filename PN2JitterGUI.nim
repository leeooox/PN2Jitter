import resource/resource
import wNim/[wApp, wFrame, wIcon, wStatusBar, wMenuBar, wMenu, wFont,
  wBitmap, wImage, wPanel, wStaticText, wTextCtrl, wButton, wMessageDialog]
import strutils, math, strformat
import PN2Jitter

const
  H = 23
  S = 7

let app = App()
let frame = Frame(title="Phase Noise to Jitter Calculator",size=(600, 700))
frame.icon = Icon("", 0) # load icon from exe file.

let panel = Panel(frame)

var
  txt_f:array[15, wTextCtrl]
  txt_p:array[15, wTextCtrl]
  txt_j:array[14, wTextCtrl]


let lbl_c = StaticText(panel, label="Center Frequency:", pos=(10, 10), size=(100, H), style=wAlignLeft)
let txt_fc = TextCtrl(panel, value="200e6", pos=(120 , 10) , size=(100,H), style=wBorderStatic)

discard StaticText(panel, label="Frequency Offset:", pos=(10, 50), style=wAlignLeft)
discard StaticText(panel, label="Phase Noise:", pos=(170, 50), style=wAlignLeft)

var h1 =0
for i in 0..14:
  h1 = i*(H+S)+80
  txt_f[i] = TextCtrl(panel, value= "", pos=(10 , h1) , size=(100,H), style=wBorderSimple)
  discard StaticText(panel, label="Hz", pos=(115, h1), size=(40, H), style=wAlignLeft)
  txt_p[i] = TextCtrl(panel, value= "", pos=(170, h1) , size=(100,H), style=wBorderSimple)
  discard StaticText(panel, label="dBc/Hz", pos=(275, h1), size=(40, H), style=wAlignLeft)
  if i>0 :
    txt_j[i-1] = TextCtrl(panel, value="", pos=(360, h1) , size=(100,H), style=wBorderSunken)
    #txt_j[i-1].enable(false)
    discard StaticText(panel, label="ps", pos=(462, h1), size=(40, H), style=wAlignLeft)
  else:
    discard StaticText(panel, label="Segment RMS Jitter", pos=(360, h1), size=(160, H), style=wAlignLeft)

let h2 = 545
let btn_calc = Button(panel, label="Caculate", pos = (10,h2),size=(100,30))
btn_calc.font = Font(12, family=wFontFamilySwiss, weight=wFontWeightBold)
discard StaticText(panel, label="Summed Jitter:", pos=(270, h2), style=wAlignLeft)
let txt_jsum = TextCtrl(panel, value= "", pos=(360, h2) , size=(100,H), style=wBorderSunken)
#txt_jsum.enable(false)
discard StaticText(panel, label="ps", pos=(462, h2), size=(40, H), style=wAlignLeft)

let h3 = 590
discard StaticText(panel, label="PN2Jitter: a phase noise to jitter calculator. Rev0.0\nCopyright 2020 by leeooox@gmail.com", 
  pos=(80, h3), size=(500,60))

const
  FINIT = ["1e2","1e3","1e4","1e5","1e6","1e7"]
  PINIT = ["-85","-115","-125","-128","-147","-158"]
for i, val in FINIT:
  txt_f[i].setValue(FINIT[i])
  txt_p[i].setValue(PINIT[i])



proc calc_jitter() =
  var
    f:seq[float]
    lf:seq[float]
  for i in 0.. txt_f.len:
    if txt_f[i].getValue()=="" or txt_p[i].getValue()=="":
      break
    else:
      f.add(parseFloat(txt_f[i].getValue()))
      lf.add(parseFloat(txt_p[i].getValue()))
  let fc = parseFloat(txt_fc.getValue())
  let pn = PhaseNoise(f:f,lf:lf,fc:fc)
  let jit = PN2Jitter(pn)
  txt_jsum.setValue(fmt"{jit.sum*1e12:g}")

  for i,val in jit.segment:
    txt_j[i].setValue(fmt"{val*1e12:g}")

btn_calc.wEvent_Button do ():
  calc_jitter()

frame.center()
frame.show()
app.mainLoop()

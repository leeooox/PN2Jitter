import math,sequtils
type
  Jitter = object
    segment : seq[float]
    sum     : float
    f       : seq[float]

type
  PhaseNoise = object
    f       : seq[float]
    lf      : seq[float]
    fc      : float

proc diff[T](seqin:openArray[T]) : seq[T] =
  for i in 0..(seqin.len-2):
    result.add(seqin[i+1] - seqin[i])

proc `/`[T](a,b:openArray[T]) : seq[T] = 
  for i in 0..<a.len:
    result.add(a[i]/b[i])

proc `/`[T](a:openArray[T], b:T) : seq[T] = 
  for i in 0..<a.len:
    result.add(a[i]/b)

proc `pow`[T](b:T,a:openArray[T]) : seq[T] = 
  result = map(a, proc(x:T):T=pow(b,x))

proc `log10`[T](a:openArray[T]) : seq[T] = 
  result = map(a, proc(x:T):T=log10(x))


proc PN2Jitter(pn:PhaseNoise): Jitter = 
  var lf_diff : seq[float]
  let 
    lf = pn.lf
    f = pn.f
    fc = pn.fc
  lf_diff = diff(lf)
  echo lf_diff
  for i in 0 ..< lf_diff.len:
    if lf_diff[i] == -10:
      lf_diff[i] += float(i+1)/1.0e8
  let ai = lf_diff/diff(log10(f))

  result.f = f
  for i in 0 ..< ai.len:
    let jit_tmp = pow(10, lf[i] / 10.0) * pow(f[i], -ai[i] / 10.0) / (ai[i] / 10.0 + 1) * 
      (pow(f[i + 1], ai[i] / 10.0 + 1) - pow(f[i], ai[i] / 10.0 + 1))
    let jit_seg = 1 / (2 * PI*fc) * sqrt(2 * jit_tmp)
    result.segment.add(jit_seg)
    result.sum += jit_tmp

  result.sum = 1 / (2 * PI*fc) * sqrt(2 * result.sum)

when isMainModule:
  var
    f = @[1E2,1E3,1E4,1E5,1E6,1E7]
    lf= @[-85.0,-115,-125,-128,-147,-158]
    fc = 245e6
  let pn = PhaseNoise(f:f,lf:lf,fc:fc)
  let jit = PN2Jitter(pn)
  echo jit.f
  echo jit.segment
  echo jit.sum

  

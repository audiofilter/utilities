#!/usr/bin/python
"""
__version__ = "$Revision: 1.3 $"
__date__ = "$Date: Tue Sep 05 20:29:58 2006
"""

"""
this is a blah blah blah
"""

from PythonCard import clipboard, dialog, graphic, model, timer
import wx
import os
import random
import math
import sys
import wave
import pyaudio

from pychirp.rx_audio import *

from numpy import *
from scipy.signal import freqz
from scipy.signal import zpk2tf

pts = 500
#d = array(zeros(pts),'d')

dev = pyaudio.PyAudio()
stream = dev.open(format = 8, channels = 2,rate = 22050,output = True)
play_ok = 0
set_module_and_type('numpy','ndarray')

class Madplot(model.Background):

    def on_initialize(self, event):
        self.filename = None
        comp = self.components
        self.sliderLabels = {
        'stcWeight':comp.stcWeight.text,
        'stcPassband':comp.stcPassband.text,
        'stctrans':comp.stctrans.text,
        'stcRate':comp.stcRate.text,
        'stcFreq':comp.stcFreq.text,
        }
        self.setSliderLabels()
        self.components.bufOff.backgroundColor = 'white'
        self.components.bufOff.clear()
        self.play_ok = 0
        self.doMadplot()
        
    def doMadplot(self):
        comp = self.components
        
        canvas = comp.bufOff
        width, height = canvas.size
        xOffset = width / 2
        yOffset = height / 2


        pass_edge = comp.sldPassband.value/2000.0
        trans = pass_edge*comp.sldtrans.value/2000.0
        notch_trans = 1.0-comp.sldtrans.value/1000.0
        self.rate = comp.sldRate.value/1000.0
        self.freq = comp.sldFreq.value/1000.0
        stop_edge = pass_edge + trans
        if (stop_edge > 0.42):
            stop_edge = 0.42
        stop_dBs = -comp.sldWeight.value/10
        stop_weight = 10**(-stop_dBs/20.0)
        ripple = stop_weight
        if(ripple>1):  ripple = 1
        self.notch_freq = pass_edge
        self.notch_depth = stop_weight
        order = 8

        #BF = cutboost_double(pass_edge,notch_trans,stop_weight)
        #[w,z] = self.other_freq(BF)
        color = 'red'
        canvas.foregroundColor = color
        canvas.autoRefresh = 0
        canvas.clear()
        lastX = 0
        lastY = yOffset
        self.keepDrawing = 1
        points = []
        grid  = []
        for i in xrange(10):
            y_grid = i*height/10
            grid.append((0, y_grid, width, y_grid))
        grid.append((0, height-1, width, height-1))

        for i in xrange(10):
            x_grid = i*width/10
            grid.append((x_grid, 0, x_grid, height))
        grid.append((width-1, 0, width-1, height))

        canvas.drawLineList(grid)
        canvas.foregroundColor = 'blue'
        
        for i in xrange(pts):
            #x = pts*(w[i]/pi)
            #y = yOffset - 0.01*height*z[i]
            x = pts*(i/pi)
            y = yOffset - 0.01*height*i
            points.append((lastX, lastY, x, y))
            lastX = x
            lastY = y

        canvas.drawLineList(points)
        canvas.autoRefresh = 1
        canvas.refresh()

            
    def on_select(self, event):
        name = event.target.name
        # only process Sliders
        if name.startswith('sld'):
            labelName = 'stc' + name[3:]
            self.components[labelName].text = self.sliderLabels[labelName] + \
                ' ' + str(event.target.value)
        self.play_ok = 0
        self.doMadplot()
        self.play_ok = 1

    def setSliderLabels(self):
        comp = self.components
        for key in self.sliderLabels:
            sliderName = 'sld' + key[3:]
            comp[key].text = self.sliderLabels[key] + ' ' + str(comp[sliderName].value)

    def on_menuFileSaveAs_select(self, event):
        if self.filename is None:
            path = ''
            filename = ''
        else:
            path, filename = os.path.split(self.filename)

    def on_menuEditCopy_select(self, event):
        clipboard.setClipboard(self.components.bufOff.getBitmap())

    def on_menuEditPaste_select(self, event):
        bmp = clipboard.getClipboard()
        if isinstance(bmp, wx.Bitmap):
            self.components.bufOff.drawBitmap(bmp)

    def on_editClear_command(self, event):
        self.components.bufOff.clear()

    def other_freq(self,AP):
        imp = 1
        sum = 0
        d = array(zeros(pts),'d')
        for i in xrange(pts):
            d[i] = AP.clock(imp)
            sum = sum+d[i]
            imp = 0
        [w,h] = freqz(d,1,pts)
        z = 20*log10(abs(h/h[0]))
        return w,z,

    def on_audioCtrl_command(self, event):
        if self.components.audioPlay.stringSelection == 'Play':
            self.play_ok = 1
            self.play()
        else:
            self.play_ok = 0

    def play(self):
        audio_buf = array(zeros(514),'i')
        while self.components.audioPlay.stringSelection == 'Play' and self.play_ok:
            freq = 10.0*self.freq
            if self.components.Signal.stringSelection == 'Tone':
                audio_tone(audio_buf,freq,self.rate)
            else:
                gain = 0.25
                rate = 100.0*self.rate
                #print freq,rate,gain
                audio_fsk(audio_buf,freq,rate,gain)
            #audio_butterworth(audio_buf,self.notch_freq)
            buffy = buffer(audio_buf)
            stream.write(buffy)
            wx.SafeYield(self, True)

if __name__ == '__main__':
    app = model.Application(Madplot)
    app.MainLoop()

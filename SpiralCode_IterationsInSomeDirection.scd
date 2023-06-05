s.boot;

(
~size = 300;
~sizeHalf = ~size * 0.5;
)


// now you can put an image at each point in the spiral instead of a square
(
Routine {
	var elemW, nTimesElem, incElem, aElem, bElem, srcImgFilePathElem, srcImgHeightElem, srcImgWidthElem, vizScaleElem, imgScanIncElem, xDivsElem, yDivsElem, sndRateElem, sndFadeOutTimeElem, sndFadeInTimeElem, newVal;
	var nTimes = 500;
	var inc = 0.1;
	var a = 0;
	var b = 1.1;
	var srcImgFilePath = "/Users/DJMac/Documents/MalinowskiDJMusic/MyCompositions/NewIdeas/2023Spring/elevator/shepardTone/elevatorDoors/underwater_likeDrawn_1.png";
	var srcImgHeight = 5;
	var srcImgWidth = 5;
	var vizScale = 3;
	var xDivs = 3;
	var yDivs = 3;
	var imgScanInc = 1; // in order to cover every pixel: only odd numbers, but nothing divisible by 3, and maybe nothing divisible by 5?
	var sndRate = 1;
	var sndFadeOutTime = 1;
	var sndFadeInTime = 0.5;
	var freqStart = 100;
	var freqEnd = 600;
	var newSpiralW;
	var synth;
	newVal = {
		w.close;
		synth.release(sndFadeOutTimeElem.value.asFloat);
		newSpiralW.value;
	};
	elemW = Window("", Rect(~size,0, 250, ~size)).front;
	elemW.view.decorator = FlowLayout(elemW.view.bounds, 10@10, 20@5);
	StaticText(elemW, 105@20).string_("nTimes");
	nTimesElem = TextField(elemW, 100@20).value_(nTimes).action_(newVal);
	StaticText(elemW, 105@20).string_("inc");
	incElem = TextField(elemW, 100@20).value_(inc).action_(newVal);
	StaticText(elemW, 105@20).string_("a");
	aElem = TextField(elemW, 100@20).value_(a).action_(newVal);
	StaticText(elemW, 105@20).string_("b");
	bElem = TextField(elemW, 100@20).value_(b).action_(newVal);
	StaticText(elemW, 105@20).string_("srcImgFilePath");
	srcImgFilePathElem = TextField(elemW, 100@20).value_(srcImgFilePath).action_(newVal);
	StaticText(elemW, 105@20).string_("srcImgFileHeight");
	srcImgHeightElem = TextField(elemW, 100@20).value_(srcImgHeight).action_(newVal);
	StaticText(elemW, 105@20).string_("srcImgWidth");
	srcImgWidthElem = TextField(elemW, 100@20).value_(srcImgWidth).action_(newVal);
	StaticText(elemW, 105@20).string_("vizScale");
	vizScaleElem = TextField(elemW, 100@20).value_(vizScale).action_(newVal);
	StaticText(elemW, 105@20).string_("imgScanInc");
	imgScanIncElem = TextField(elemW, 100@20).value_(imgScanInc).action_(newVal);
	StaticText(elemW, 105@20).string_("xDivs");
	xDivsElem = TextField(elemW, 100@20).value_(xDivs).action_(newVal);
	StaticText(elemW, 105@20).string_("yDivs");
	yDivsElem = TextField(elemW, 100@20).value_(yDivs).action_(newVal);
	StaticText(elemW, 105@20).string_("sndRate");
	sndRateElem = TextField(elemW, 100@20).value_(sndRate).action_(newVal);
	StaticText(elemW, 105@20).string_("sndFadeOutTime");
	sndFadeOutTimeElem = TextField(elemW, 100@20).value_(sndFadeOutTime).action_(newVal);
	StaticText(elemW, 105@20).string_("sndFadeInTime");
	sndFadeInTimeElem = TextField(elemW, 100@20).value_(sndFadeInTime).action_(newVal);

	s.sync;

	newSpiralW = {
		Routine {
			var loc = Polar(30,1);
			var srcImg = Image.open(srcImgFilePathElem.value.asString);
			var img, imgArr, imgArrMax;
			var pixelLoc = 0;
			var sndArrMid = [];
			var xTotalSize, yTotalSize;
			var aDir = [];
			var sndArr;
			var arrBuf;
			w = Window("", Rect(0,0,~size, ~size)).front;
			w.view.background_(Color.white);
			w.drawFunc = {
				Pen.translate(~sizeHalf, ~sizeHalf);
				Pen.scale(vizScaleElem.value.asFloat, vizScaleElem.value.asFloat);
				nTimesElem.value.asFloat.do{
					Pen.drawImage(Rect(loc.asPoint.x, loc.asPoint.y, srcImgWidthElem.value.asFloat, srcImgHeightElem.value.asFloat), srcImg);
					loc.theta = (loc.theta + incElem.value.asFloat) % 360;
					loc.rho = (loc.theta * bElem.value.asFloat) + aElem.value.asFloat;
				};
			};
			w.refresh;
			s.sync;
			img = Image.fromWindow(w, Rect(0,0,~size,~size));
			imgArr = img.pixels;
			s.sync;
			imgArr = (imgArr + 1) * (-1);
			imgArr = imgArr / (imgArr.maxItem);
			imgArr.size.do({
				sndArrMid = sndArrMid.add(imgArr[pixelLoc]);
				pixelLoc = (pixelLoc + imgScanIncElem.value.asFloat) % (imgArr.size);
			});
			s.sync;

			// designating sections/parts to scan
			xTotalSize = imgArr.size.sqrt.asInt;
			yTotalSize = xTotalSize.copy;
			yDivsElem.value.asInt.do({ |iy|
				(yTotalSize / yDivsElem.value.asInt).do({
					xDivsElem.value.asInt.do({ |ix|
						(xTotalSize / xDivsElem.value.asInt).do({
							aDir = aDir.add(ix + (iy * xDivsElem.value.asInt));
						});
					});
				});
			});
			s.sync;
			sndArr = Array.fill((xDivsElem.value.asInt) * (yDivsElem.value.asInt), {[]});
			aDir.size.do({ |i|
				sndArr[aDir[i]] = sndArr[aDir[i]].add(sndArrMid[i]);
			});
			sndArr = sndArr.flatten;
			s.sync;

			arrBuf = Buffer.loadCollection(s, sndArr);
			s.sync;
			synth = {
				var sr = SampleRate.ir;
				var rate = sndRateElem.value.asFloat;
				var dur = (imgArr.size) / (sr * rate);
				var ampEnv = EnvGen.ar(Env.new([0,1], [sndFadeInTimeElem.value.asFloat], 'sin'));
				//var ampEnv = EnvGen.ar(Env.linen(dur * 0.5, dur * 0, dur * 0.5, curve: 'sine'), Impulse.ar(dur.reciprocal));
				//var freq = LinExp.ar(Phasor.ar(0, rate / (imgArr.size), 0, 1), 0, 1, freqStart, freqEnd);
				var freq = 100;
				var snd = PlayBuf.ar(1, arrBuf, rate, loop:1);
				//snd = SinOsc.ar(freq, 0, snd) * ampEnv;
				snd;
			}.play;
		}.play(AppClock);
	};
	newSpiralW.value;
}.play(AppClock);
)



// now it scrubs thru an audio file/sample instead of converting directly to audio voltages

~thxBuf = Buffer.read(s, "/Users/DJMac/Documents/MalinowskiDJMusic/MyCompositions/NewIdeas/2023Spring/elevator/shepardTone/shepardTone_RecordedTracks/THX_theme.aiff");

(
Routine {
	var elemW, nTimesElem, incElem, aElem, bElem, srcImgFilePathElem, srcImgHeightElem, srcImgWidthElem, vizScaleElem, imgScanIncElem, xDivsElem, yDivsElem, sndRateElem, sndFadeOutTimeElem, sndFadeInTimeElem, newVal;
	var nTimes = 500;
	var inc = 0.1;
	var a = 0;
	var b = 1.1;
	var srcImgFilePath = "/Users/DJMac/Documents/MalinowskiDJMusic/MyCompositions/NewIdeas/2023Spring/elevator/shepardTone/elevatorDoors/underwater_likeDrawn_1.png";
	var srcImgHeight = 5;
	var srcImgWidth = 5;
	var vizScale = 3;
	var xDivs = 3;
	var yDivs = 3;
	var imgScanInc = 1; // in order to cover every pixel: only odd numbers, but nothing divisible by 3, and maybe nothing divisible by 5?
	var sndRate = 1;
	var sndFadeOutTime = 1;
	var sndFadeInTime = 0.5;
	var freqStart = 100;
	var freqEnd = 600;
	var newSpiralW;
	var synth;
	newVal = {
		w.close;
		synth.release(sndFadeOutTimeElem.value.asFloat);
		newSpiralW.value;
	};
	elemW = Window("", Rect(~size,0, 250, ~size)).front;
	elemW.view.decorator = FlowLayout(elemW.view.bounds, 10@10, 20@5);
	StaticText(elemW, 105@20).string_("nTimes");
	nTimesElem = TextField(elemW, 100@20).value_(nTimes).action_(newVal);
	StaticText(elemW, 105@20).string_("inc");
	incElem = TextField(elemW, 100@20).value_(inc).action_(newVal);
	StaticText(elemW, 105@20).string_("a");
	aElem = TextField(elemW, 100@20).value_(a).action_(newVal);
	StaticText(elemW, 105@20).string_("b");
	bElem = TextField(elemW, 100@20).value_(b).action_(newVal);
	StaticText(elemW, 105@20).string_("srcImgFilePath");
	srcImgFilePathElem = TextField(elemW, 100@20).value_(srcImgFilePath).action_(newVal);
	StaticText(elemW, 105@20).string_("srcImgFileHeight");
	srcImgHeightElem = TextField(elemW, 100@20).value_(srcImgHeight).action_(newVal);
	StaticText(elemW, 105@20).string_("srcImgWidth");
	srcImgWidthElem = TextField(elemW, 100@20).value_(srcImgWidth).action_(newVal);
	StaticText(elemW, 105@20).string_("vizScale");
	vizScaleElem = TextField(elemW, 100@20).value_(vizScale).action_(newVal);
	StaticText(elemW, 105@20).string_("imgScanInc");
	imgScanIncElem = TextField(elemW, 100@20).value_(imgScanInc).action_(newVal);
	StaticText(elemW, 105@20).string_("xDivs");
	xDivsElem = TextField(elemW, 100@20).value_(xDivs).action_(newVal);
	StaticText(elemW, 105@20).string_("yDivs");
	yDivsElem = TextField(elemW, 100@20).value_(yDivs).action_(newVal);
	StaticText(elemW, 105@20).string_("sndRate");
	sndRateElem = TextField(elemW, 100@20).value_(sndRate).action_(newVal);
	StaticText(elemW, 105@20).string_("sndFadeOutTime");
	sndFadeOutTimeElem = TextField(elemW, 100@20).value_(sndFadeOutTime).action_(newVal);
	StaticText(elemW, 105@20).string_("sndFadeInTime");
	sndFadeInTimeElem = TextField(elemW, 100@20).value_(sndFadeInTime).action_(newVal);

	s.sync;

	newSpiralW = {
		Routine {
			var loc = Polar(30,1);
			var srcImg = Image.open(srcImgFilePathElem.value.asString);
			var img, imgArr, imgArrMax;
			var pixelLoc = 0;
			var sndArrMid = [];
			var xTotalSize, yTotalSize;
			var aDir = [];
			var sndArr;
			var arrBuf;
			w = Window("", Rect(0,0,~size, ~size)).front;
			w.view.background_(Color.white);
			w.drawFunc = {
				Pen.translate(~sizeHalf, ~sizeHalf);
				Pen.scale(vizScaleElem.value.asFloat, vizScaleElem.value.asFloat);
				nTimesElem.value.asFloat.do{
					Pen.drawImage(Rect(loc.asPoint.x, loc.asPoint.y, srcImgWidthElem.value.asFloat, srcImgHeightElem.value.asFloat), srcImg);
					loc.theta = (loc.theta + incElem.value.asFloat) % 360;
					loc.rho = (loc.theta * bElem.value.asFloat) + aElem.value.asFloat;
				};
			};
			w.refresh;
			s.sync;
			img = Image.fromWindow(w, Rect(0,0,~size,~size));
			imgArr = img.pixels;
			s.sync;
			imgArr = (imgArr + 1) * (-1);
			imgArr = imgArr / (imgArr.maxItem);
			imgArr.size.do({
				sndArrMid = sndArrMid.add(imgArr[pixelLoc]);
				pixelLoc = (pixelLoc + imgScanIncElem.value.asFloat) % (imgArr.size);
			});
			s.sync;

			// designating sections/parts to scan
			xTotalSize = imgArr.size.sqrt.asInt;
			yTotalSize = xTotalSize.copy;
			yDivsElem.value.asInt.do({ |iy|
				(yTotalSize / yDivsElem.value.asInt).do({
					xDivsElem.value.asInt.do({ |ix|
						(xTotalSize / xDivsElem.value.asInt).do({
							aDir = aDir.add(ix + (iy * xDivsElem.value.asInt));
						});
					});
				});
			});
			s.sync;
			sndArr = Array.fill((xDivsElem.value.asInt) * (yDivsElem.value.asInt), {[]});
			aDir.size.do({ |i|
				sndArr[aDir[i]] = sndArr[aDir[i]].add(sndArrMid[i]);
			});
			sndArr = sndArr.flatten;
			s.sync;

			arrBuf = Buffer.loadCollection(s, sndArr);
			s.sync;
			synth = {
				var sr = SampleRate.ir;
				var rate = sndRateElem.value.asFloat;
				var dur = (imgArr.size) / (sr * rate);
				var ampEnv = EnvGen.ar(Env.new([0,1], [sndFadeInTimeElem.value.asFloat], 'sin'));
				//var ampEnv = EnvGen.ar(Env.linen(dur * 0.5, dur * 0, dur * 0.5, curve: 'sine'), Impulse.ar(dur.reciprocal));
				//var freq = LinExp.ar(Phasor.ar(0, rate / (imgArr.size), 0, 1), 0, 1, freqStart, freqEnd);
				var freq = 100;
				//var snd = PlayBuf.ar(1, arrBuf, rate, loop:1);
				var bufRate = PlayBuf.ar(1, arrBuf, rate, loop:1);
				var snd = PlayBuf.ar(2, ~thxBuf, BufRateScale.ir(~thxBuf) * bufRate * 5, loop:1);
				//var snd = BufRd.ar(2, ~thxBuf, bufRate * BufFrames.ir(~thxBuf));
				//snd = SinOsc.ar(freq, 0, snd) * ampEnv;
				snd;
			}.play;
		}.play(AppClock);
	};
	newSpiralW.value;
}.play(AppClock);
)